# frozen_string_literal: true

module Reconciliations
  class CompleteReconciliation
    include Interactor
    include ErrorHandling

    def call
      reconciliation = context.reconciliation
      result = context.match_result

      reconciliation.assign_attributes(
        status: :completed,
        matched_count: result.matched.size,
        bank_only_count: result.bank_only.size,
        processor_only_count: result.processor_only.size,
        discrepancy_count: result.discrepancies.size,
        report: context.report,
        processed_at: Time.current
      )
      reconciliation.save!(validate: false)
    rescue ActiveRecord::RecordInvalid => e
      fail_with!(ErrorCodes::VALIDATION_ERROR, message: e.message)
    end
  end
end
