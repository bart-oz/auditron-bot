# frozen_string_literal: true

class Reconciliation < ApplicationRecord
  # Allowed content types for uploaded files
  BANK_FILE_CONTENT_TYPES = ["text/csv", "text/plain", "application/csv"].freeze
  PROCESSOR_FILE_CONTENT_TYPES = ["application/json", "text/json", "text/plain"].freeze

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
    validate_bank_file_content_type
    validate_processor_file_content_type
  end

  def validate_bank_file_content_type
    return unless bank_file.attached?

    content_type = bank_file.blob.content_type
    return if BANK_FILE_CONTENT_TYPES.include?(content_type)

    errors.add(:bank_file, "must be a CSV file")
  end

  def validate_processor_file_content_type
    return unless processor_file.attached?

    content_type = processor_file.blob.content_type
    return if PROCESSOR_FILE_CONTENT_TYPES.include?(content_type)

    errors.add(:processor_file, "must be a JSON file")
  end
end
