class Assessment < ApplicationRecord
  belongs_to :enrollment
  belongs_to :assignment

  has_many_attached :files, dependent: :destroy

  validates :score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
