RSpec.describe Users::BulkCreateUsers do
  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, organization: organization) }
  let(:incoming_role) { :teacher }
  let(:csv_content) do
    <<~CSV
      email
      user1@example.com
      user2@example.com
    CSV
  end
  let(:file) { StringIO.new(csv_content) }

  subject do
    described_class.new(
      current_user: current_user,
      file: file,
      incoming_role: incoming_role
    )
  end

  describe '#execute' do
    context 'when incoming_role is disallowed admin' do
      let(:incoming_role) { :global_admin }

      it 'returns nil and adds error' do
        result = subject.execute

        expect(result).to be_nil
        expect(subject.errors.full_messages).to include("Org admins cannot create 'global_admin' users")
      end
    end

    context 'when incoming_role is not allowed' do
      let(:incoming_role) { :some_invalid_role }

      it 'returns nil and adds error' do
        result = subject.execute

        expect(result).to be_nil
        expect(subject.errors.full_messages).to include("Role 'some_invalid_role' not allowed")
      end
    end

    context 'when CSV parsing fails' do
      let(:file) { StringIO.new("invalid,csv\nno header") }

      before do
        allow(CSV).to receive(:parse).and_raise(CSV::MalformedCSVError.new("bad CSV", 1))
      end

      it 'returns nil and adds parse error' do
        result = subject.execute

        expect(result).to be_nil
        expect(subject.errors.full_messages.join).to include("Failed to parse CSV: bad CSV")
      end
    end

    context 'when CSV parsing succeeds' do
      let(:csv_content) do
        <<~CSV
          email
          user1@example.com
          user2@example.com
        CSV
      end

      let(:file) { StringIO.new(csv_content) }

      before do
        # Stub Users::CreateUser to simulate creating users
        allow(Users::CreateUser).to receive(:run) do |args|
          email = args[:email]
          if email == 'user1@example.com'
            double('result', valid?: true, result: instance_double(User, email: email), errors: nil)
          else
            double('result', valid?: false, result: nil, errors: double(full_messages: [ 'Email already taken' ]))
          end
        end
      end

      it 'returns created and failed users info' do
        result = subject.execute

        expect(result).to be_a(Hash)
        expect(result[:created].map(&:email)).to eq([ 'user1@example.com' ])
        expect(result[:failed].first[:email]).to eq('user2@example.com')
        expect(result[:failed].first[:errors]).to include('Email already taken')
      end
    end
  end
end
