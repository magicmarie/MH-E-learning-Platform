class Resource < ApplicationRecord
  belongs_to :course

  has_many_attached :files, dependent: :destroy
end
