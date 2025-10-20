class Assessment < ApplicationRecord
  belongs_to :enrollment
  belongs_to :assignment

  has_many_attached :files, dependent: :destroy

  attr_accessor :current_user

  before_save :set_timestamps
  after_commit :send_email_notification, on: :update, if: :should_notify?

  validates :score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  private

  def set_timestamps
    return unless current_user

    if current_user.teacher? || current_user.org_admin?
      self.assessed_on = Time.current
    elsif current_user.student?
      self.submitted_at = Time.current
    end
  end

  # Email sending after successful save
  def send_email_notification
    return unless enrollment&.user&.email.present?

    AssessmentMailer.welcome_user(self, enrollment.user.email).deliver_later
  rescue => e
    Rails.logger.error("Failed to send assessment email to #{enrollment.user.email}: #{e.message}")
  end

  def should_notify?
    submitted_at_previously_changed? || assessed_on_previously_changed?
  end
end
