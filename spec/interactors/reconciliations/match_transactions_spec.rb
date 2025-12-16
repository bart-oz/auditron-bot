# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reconciliations::MatchTransactions do
  describe ".call" do
    let(:bank_transactions) { [{ id: "TXN001", amount: 100.0 }] }
    let(:processor_transactions) { [{ id: "TXN001", amount: 100.0 }] }
    let(:match_result) do
      TransactionMatcher::Result.new(
        matched: [{ id: "TXN001" }],
        bank_only: [],
        processor_only: [],
        discrepancies: []
      )
    end

    before do
      allow(TransactionMatcher).to receive(:call).and_return(match_result)
    end

    it "matches transactions and stores result in context" do
      result = described_class.call(
        bank_transactions:,
        processor_transactions:
      )

      expect(result).to be_success
      expect(result.match_result).to eq(match_result)
    end

    it "calls TransactionMatcher with correct arguments" do
      described_class.call(bank_transactions:, processor_transactions:)

      expect(TransactionMatcher).to have_received(:call).with(
        bank_transactions:,
        processor_transactions:
      )
    end
  end
end
