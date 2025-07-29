# spec/mailers/assessment_mailer_spec.rb
require "rails_helper"

RSpec.describe AssessmentMailer, type: :mailer do
  describe "#welcome_user" do
    let(:organization) { create(:organization) }
    let(:teacher) { create(:user, :teacher, organization: organization) }
    let(:assignment) { create(:assignment, assignment_type: "Quiz") }
    let(:student) { create(:user, organization: organization) }
    let(:course) { create(:course, user: teacher, organization: organization) }
    let(:enrollment) { create(:enrollment, course: course, user: student) }
    let(:assessment) do
      create(
        :assessment,
        assignment: assignment,
        enrollment: enrollment,
        score: 87,
        updated_at: Time.zone.parse("2024-04-01 15:30")
      )
    end
    let(:user_email) { student.email }
    let(:mail) { described_class.welcome_user(assessment, user_email).deliver_now }

    it "renders the headers" do
    expect(mail.subject).to eq("Assessment update!")
    expect(mail.to).to eq([ user_email ])
    expect(mail.from).to eq([ "natukunda162@gmail.com" ])
  end

  it "assigns instance variables for the email template" do
    expect(mail.body.encoded).to include(assignment.assignment_type.to_s)
    expect(mail.body.encoded).to include(assessment.score.to_s)
    expect(mail.body.encoded).to include(assessment.updated_at.strftime("%B %d, %Y at %I:%M %p"))
  end
  end
end
