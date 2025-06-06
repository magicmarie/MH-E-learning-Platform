class Organization < ApplicationRecord
  has_many :users

  validates :name, presence: true
  validates :organization_code,
    presence: true,
    uniqueness: true,
    format: { with: /\A[a-zA-Z0-9\-_]+\z/, message: "only allows letters, numbers, dashes, and underscores" },
    length: { minimum: 6, maximum: 6, message: "must be exactly 6 characters long" }
end
