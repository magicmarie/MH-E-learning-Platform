require "csv"

RSpec.describe Admin::Users::BulkCreateUsers do
  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :org_admin, organization: organization) }

  let(:csv_content) do
    <<~CSV
      email,name
      user1@example.com,User One
      user2@example.com,User Two
    CSV
  end

  let(:file) { StringIO.new(csv_content) }

  # Convert CSV rows to array of hashes for users_data
  let(:users_data) do
    CSV.parse(file, headers: true).map do |row|
      { email: row["email"], name: row["name"] }
    end
  end

  before do
    allow(JsonWebToken).to receive(:encode).and_return("mock_token")
    allow(UserMailer).to receive_message_chain(:welcome_user, :deliver_now)
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
  end

  describe "#execute" do
    subject(:bulk_create) do
      described_class.run(
        current_user: current_user,
        users_data: users_data,
        incoming_role: incoming_role,
        organization_id: organization.id
      )
    end

    context "with valid role" do
      let(:incoming_role) { :student }

      it "creates all users successfully from CSV" do
        interaction = bulk_create
        result = interaction.result

        expect(result[:created].size).to eq(2)
        expect(result[:failed]).to be_empty

        result[:created].each do |user|
          expect(user).to be_a(User)
          expect(user.organization).to eq(organization)
          expect(UserMailer).to have_received(:welcome_user).with(user, kind_of(String), kind_of(String))
        end
        expect(interaction.errors).to be_empty
      end
    end

    context "with global_admin role" do
      let(:incoming_role) { :global_admin }

      it "does not create users and adds an error" do
        interaction = bulk_create
        expect(interaction.result).to be_nil
        expect(interaction.errors.full_messages).to include("Cannot create global_admin")
      end
    end

    context "with disallowed role" do
      let(:incoming_role) { :invalid_role }

      it "does not create users and adds an error" do
        interaction = bulk_create
        expect(interaction.result).to be_nil
        expect(interaction.errors.full_messages).to include("Role 'invalid_role' not allowed")
      end
    end

    context "when organization does not exist" do
      let(:incoming_role) { :student }

      subject(:bulk_create) do
        described_class.run(
          current_user: current_user,
          users_data: users_data,
          incoming_role: incoming_role,
          organization_id: 0
        )
      end

      it "does not create users and adds an error" do
        interaction = bulk_create
        expect(interaction.result).to be_nil
        expect(interaction.errors.full_messages).to include("Organization not found")
      end
    end

    context "when some users fail validation" do
      let(:incoming_role) { :student }

      let(:csv_content) do
        <<~CSV
          email,name
          user1@example.com,User One
          ,User Two
        CSV
      end

      it "creates valid users and reports failed ones" do
        interaction = bulk_create
        result = interaction.result

        expect(result[:created].size).to eq(1)
        expect(result[:created].first.email).to eq("user1@example.com")

        expect(result[:failed].size).to eq(1)
        expect(result[:failed].first[:email]).to be_nil
        expect(result[:failed].first[:errors]).to include("Email can't be blank")
      end
    end

    context "when Pundit denies authorization" do
      let(:incoming_role) { :student }

      before do
        allow_any_instance_of(ApplicationController).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      end

      it "reports users as failed due to authorization" do
        interaction = bulk_create
        result = interaction.result

        expect(result[:created]).to be_empty
        expect(result[:failed].size).to eq(2)
        result[:failed].each do |f|
          expect(f[:errors]).to include("Not authorized to create user")
        end
      end
    end
  end
end
