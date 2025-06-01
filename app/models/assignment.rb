class Assignment < ApplicationRecord
  belongs_to :course
  has_many_attached :files, dependent: :destroy
  has_many :assessments, dependent: :destroy

  QUIZ= 0
  ASSIGNMENT = 1
  EXAM = 2
  PROJECT = 3

  validates :title, :deadline, presence: true
  validates :max_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :assignment_type, presence: true, inclusion: { in: [ QUIZ, ASSIGNMENT, EXAM, PROJECT ] }
end
