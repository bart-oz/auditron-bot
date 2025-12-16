# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reconciliations::ParseBankFile do
  describe ".call" do
    let(:reconciliation) { create(:reconciliation) }
    let(:parsed_transactions) { [{ id: "TXN001", amount: 100.0 }] }

    before do
      reconciliation.bank_file.attach(
        io: StringIO.new("date,amount\n2025-01-01,100.00"),
        filename: "bank.csv",
        content_type: "text/csv"
      )
      allow(BankFileParser).to receive(:call).and_return(parsed_transactions)
    end

    it "parses bank file and stores transactions in context" do
      result = described_class.call(reconciliation:)

      expect(result).to be_success
      expect(result.bank_transactions).to eq(parsed_transactions)
    end

    context "when parsing fails" do
      before do
        allow(BankFileParser).to receive(:call).and_raise(
          BankFileParser::ParseError, "Invalid CSV format"
        )
      end

      it "fails with validation error" do
        result = described_class.call(reconciliation:)

        expect(result).to be_failure
        expect(result.error_code).to eq(ErrorCodes::VALIDATION_ERROR)
        expect(result.error_message).to include("Bank file parsing failed")
      end
    end
  end
end
