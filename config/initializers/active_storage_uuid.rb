# frozen_string_literal: true

# Configure ActiveStorage to generate UUIDs for blob and attachment records
# This is needed because ActiveStorage::Blob and ActiveStorage::Attachment
# don't inherit from ApplicationRecord, so they don't get our UUID generation callback.

Rails.application.config.to_prepare do
  ActiveStorage::Blob.class_eval do
    before_create :set_uuid_primary_key, unless: -> { id.present? }

    private

    def set_uuid_primary_key
      self.id = SecureRandom.uuid
    end
  end

  ActiveStorage::Attachment.class_eval do
    before_create :set_uuid_primary_key, unless: -> { id.present? }

    private

    def set_uuid_primary_key
      self.id = SecureRandom.uuid
    end
  end

  ActiveStorage::VariantRecord.class_eval do
    before_create :set_uuid_primary_key, unless: -> { id.present? }

    private

    def set_uuid_primary_key
      self.id = SecureRandom.uuid
    end
  end
end
