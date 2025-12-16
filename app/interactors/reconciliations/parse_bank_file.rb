# frozen_string_literal: true

module Reconciliations
  class ParseBankFile
    include Interactor
    include ErrorHandling

    def call
      context.bank_transactions = BankFileParser.call(context.reconciliation.bank_file)
    rescue BankFileParser::ParseError => e
      fail_with!(ErrorCodes::VALIDATION_ERROR, message: "Bank file parsing failed: #{e.message}")
    end
  end
end
