# frozen_string_literal: true

module Reconciliations
  class SetProcessingStatus
    include Interactor
    include ErrorHandling

    def call
      context.reconciliation.processing!
    rescue ActiveRecord::RecordInvalid => e
      fail_with!(ErrorCodes::VALIDATION_ERROR, message: e.message)
    end
  end
end
