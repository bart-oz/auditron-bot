# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reconciliations::CompleteReconciliation do
  describe ".call" do
    subject(:result) { described_class.call(reconciliation:, match_result:, report:) }

    let(:reconciliation) { create(:reconciliation, :processing) }
    let(:match_result) do
      TransactionMatcher::Result.new(
        matched: [{ id: "TXN001" }, { id: "TXN002" }],
        bank_only: [{ id: "TXN003" }],
        processor_only: [{ id: "TXN004" }],
        discrepancies: [{ id: "TXN005" }]
      )
    end
    let(:report) { '{"summary":{}}' }

    it "succeeds" do
      expect(result).to be_success
    end

    it "sets status to completed" do
      result
      expect(reconciliation.reload).to be_completed
    end

    it "sets counts from match result" do
      result
      reconciliation.reload

      expect(reconciliation.matched_count).to eq(2)
      expect(reconciliation.bank_only_count).to eq(1)
      expect(reconciliation.processor_only_count).to eq(1)
      expect(reconciliation.discrepancy_count).to eq(1)
    end

    it "saves report and processed_at" do
      result
      reconciliation.reload

      expect(reconciliation.report).to eq(report)
      expect(reconciliation.processed_at).to be_present
    end
  end
end
