RSpec.describe UserMailer, type: :mailer do
  describe "#welcome_user" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, email: "user@example.com", organization: organization) }
    let(:temp_password) { "temporary123" }
    let(:reset_password_url) { "https://example.com/reset_password" }

    subject(:mail) { described_class.welcome_user(user, temp_password, reset_password_url) }

    it "raises ArgumentError if user is nil" do
      expect {
      described_class.welcome_user(nil, temp_password, reset_password_url).deliver_now
    }.to raise_error(ArgumentError, "User is nil in welcome_user mailer")
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to the MH-ELP Platform!")
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ "natukunda162@gmail.com" ])
    end

    it "assigns instance variables for the email template" do
      expect(mail.body.encoded).to include(user.email)
      expect(mail.body.encoded).to include(temp_password)
      expect(mail.body.encoded).to include(organization.organization_code)
      expect(mail.body.encoded).to include(organization.name)
      expect(mail.body.encoded).to include(reset_password_url)
    end
  end
end
