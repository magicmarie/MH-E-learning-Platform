RSpec.describe CoursePolicy do
  subject { described_class.new(current_user, course) }

  let(:org) { create(:organization) }
  let(:course_creator) { create(:user, :teacher, organization: org) }
  let(:course) { create(:course, organization: org, user: course_creator) }

  describe "#index?" do
    context "when user is global_admin" do
      let(:current_user) { build_stubbed(:user, :global_admin) }

      it "allows access" do
        expect(subject.index?).to eq(true)
      end
    end

    context "when user is org_admin" do
      let(:current_user) { build_stubbed(:user, :org_admin) }

      it "allows access" do
        expect(subject.index?).to eq(true)
      end
    end

    context "when user is teacher" do
      let(:current_user) { build_stubbed(:user, :teacher) }

      it "allows access" do
        expect(subject.index?).to eq(true)
      end
    end

    context "when user is student" do
      let(:current_user) { build_stubbed(:user) }

      it "allows access" do
        expect(subject.index?).to eq(true)
      end
    end

    context "when user is guest" do
      let(:current_user) { nil }

      it "denies access" do
        expect(subject.index?).to eq(false)
      end
    end
  end

  describe "#show?" do
    context "global_admin" do
      let(:current_user) { build_stubbed(:user, :global_admin) }

      it "allows access" do
        expect(subject.show?).to eq(true)
      end
    end

    context "org_admin in same org" do
      let(:current_user) { build_stubbed(:user, :org_admin, organization: org) }

      it "allows access" do
        expect(subject.show?).to eq(true)
      end
    end

    context "teacher who created the course" do
      let(:current_user) { course_creator }

      it "allows access" do
        expect(subject.show?).to eq(true)
      end
    end

    context "student enrolled in course" do
      let(:current_user) { build_stubbed(:user) }

      before do
        allow(course).to receive(:users).and_return([ current_user ])
      end

      it "allows access" do
        expect(subject.show?).to eq(true)
      end
    end

    context "student not enrolled" do
      let(:current_user) { build_stubbed(:user) }

      before do
        allow(course).to receive(:users).and_return([])
      end

      it "denies access" do
        expect(subject.show?).to eq(false)
      end
    end
  end

  describe "#create?" do
    %i[global_admin org_admin teacher].each do |role|
      context "when user is #{role}" do
        let(:current_user) { build_stubbed(:user, role) }

        it "allows creating a course" do
          expect(subject.create?).to eq(true)
        end
      end
    end

    context "when user is student" do
      let(:current_user) { build_stubbed(:user) }

      it "denies creating a course" do
        expect(subject.create?).to eq(false)
      end
    end
  end

  describe "#update?" do
    context "global_admin" do
      let(:current_user) { build_stubbed(:user, :global_admin) }

      it "allows update" do
        expect(subject.update?).to eq(true)
      end
    end

    context "org_admin" do
      let(:current_user) { build_stubbed(:user, :org_admin) }

      it "allows update" do
        expect(subject.update?).to eq(true)
      end
    end

    context "teacher who owns the course" do
      let(:current_user) { course_creator }

      it "allows update" do
        expect(subject.update?).to eq(true)
      end
    end

    context "other teacher" do
      let(:current_user) { build_stubbed(:user, :teacher) }

      it "denies update" do
        expect(subject.update?).to eq(false)
      end
    end
  end

  describe "#destroy?" do
    context "global_admin" do
      let(:current_user) { build_stubbed(:user, :global_admin) }

      it "allows destroy" do
        expect(subject.destroy?).to eq(true)
      end
    end

    context "org_admin" do
      let(:current_user) { build_stubbed(:user, :org_admin) }

      it "allows destroy" do
        expect(subject.destroy?).to eq(true)
      end
    end

    context "teacher who owns the course" do
      let(:current_user) { course_creator }

      it "allows destroy" do
        expect(subject.destroy?).to eq(true)
      end
    end

    context "other teacher" do
      let(:current_user) { build_stubbed(:user, :teacher) }

      it "denies destroy" do
        expect(subject.destroy?).to eq(false)
      end
    end
  end

  describe "Scope" do
    subject { described_class::Scope.new(current_user, Course).resolve }

    context "global_admin" do
      let(:current_user) { build_stubbed(:user, :global_admin) }

      it "returns all courses" do
        expect(subject).to include(course)
      end
    end

    context "org_admin" do
      let(:current_user) { build_stubbed(:user, :org_admin, organization: org) }

      it "returns courses in their organization" do
        expect(subject).to include(course)
      end
    end

    context "teacher" do
      let(:current_user) { course_creator }

      it "returns their own courses" do
        expect(subject).to include(course)
      end
    end

    context "student enrolled" do
      let(:student) { create(:user) }
      let(:current_user) { student }

      before do
        course.users << student
      end

      it "returns courses they're enrolled in" do
        expect(subject).to include(course)
      end
    end

    context "unauthenticated or unrelated user" do
      let(:current_user) { nil }

      it "returns nothing" do
        expect(subject).to be_empty
      end
    end
  end
end
