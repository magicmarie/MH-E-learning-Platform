class Course < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  has_many :enrollments
  has_many :users, through: :enrollments
  has_many :assignments, dependent: :destroy

  validates :name, :course_code, :semester, :month, :year, presence: true

  validates :month, inclusion: { in: 1..12, message: "must be between 1 and 12" }
  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1900, message: "must be a valid year" }

  validates :month, uniqueness: {
    scope: [ :name, :course_code, :semester, :year, :organization_id ],
    message: "must be unique for the same course details in a given year and semester"
  }

  validates :semester, presence: true, inclusion: { in: [
    Constants::Semesters::SEMESTERS[:first],
    Constants::Semesters::SEMESTERS[:second] ] }
end
