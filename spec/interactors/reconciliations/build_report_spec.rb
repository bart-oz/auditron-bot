# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reconciliations::BuildReport do
  describe ".call" do
    let(:match_result) do
      TransactionMatcher::Result.new(
        matched: [{ id: "TXN001" }],
        bank_only: [],
        processor_only: [],
        discrepancies: []
      )
    end
    let(:report_json) { '{"summary":{"matched":1}}' }

    before do
      allow(ReportBuilder).to receive(:call).and_return(report_json)
    end

    it "builds report and stores in context" do
      result = described_class.call(match_result:)

      expect(result).to be_success
      expect(result.report).to eq(report_json)
    end

    it "calls ReportBuilder with match result" do
      described_class.call(match_result:)

      expect(ReportBuilder).to have_received(:call).with(match_result)
    end
  end
end
