# frozen_string_literal: true

module Reconciliations
  class MatchTransactions
    include Interactor
    include ErrorHandling

    def call
      context.match_result = TransactionMatcher.call(
        bank_transactions: context.bank_transactions,
        processor_transactions: context.processor_transactions
      )
    end
  end
end
