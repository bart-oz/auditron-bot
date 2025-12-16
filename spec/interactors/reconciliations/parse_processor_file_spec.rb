# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reconciliations::ParseProcessorFile do
  describe ".call" do
    let(:reconciliation) { create(:reconciliation) }
    let(:parsed_transactions) { [{ id: "TXN001", amount: 100.0 }] }

    before do
      reconciliation.processor_file.attach(
        io: StringIO.new('[{"id": "TXN001", "amount": 100.0}]'),
        filename: "processor.json",
        content_type: "application/json"
      )
      allow(ProcessorFileParser).to receive(:call).and_return(parsed_transactions)
    end

    it "parses processor file and stores transactions in context" do
      result = described_class.call(reconciliation:)

      expect(result).to be_success
      expect(result.processor_transactions).to eq(parsed_transactions)
    end

    context "when parsing fails" do
      before do
        allow(ProcessorFileParser).to receive(:call).and_raise(
          ProcessorFileParser::ParseError, "Invalid JSON format"
        )
      end

      it "fails with validation error" do
        result = described_class.call(reconciliation:)

        expect(result).to be_failure
        expect(result.error_code).to eq(ErrorCodes::VALIDATION_ERROR)
        expect(result.error_message).to include("Processor file parsing failed")
      end
    end
  end
end
