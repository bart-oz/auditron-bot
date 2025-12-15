# frozen_string_literal: true

class Reconciliation < ApplicationRecord
  # Allowed content types for uploaded files
  ALLOWED_CONTENT_TYPES = ["text/csv", "text/plain", "application/csv"].freeze

  belongs_to :user

  has_one_attached :bank_file
  has_one_attached :processor_file

  enum :status, {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }, default: :pending, validate: true

  validates :status, presence: true
  validate :validate_file_content_types

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status:) }

  def files_attached?
    bank_file.attached? && processor_file.attached?
  end

  private

  def validate_file_content_types
    validate_content_type(:bank_file)
    validate_content_type(:processor_file)
  end

  def validate_content_type(attachment_name)
    attachment = public_send(attachment_name)
    return unless attachment.attached?

    content_type = attachment.blob.content_type
    return if ALLOWED_CONTENT_TYPES.include?(content_type)

    errors.add(attachment_name, "must be a CSV file")
  end
end
