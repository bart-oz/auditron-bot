# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reconciliations::SetProcessingStatus do
  describe ".call" do
    let(:reconciliation) { create(:reconciliation, status: :pending) }

    it "sets status to processing" do
      result = described_class.call(reconciliation:)

      expect(result).to be_success
      expect(reconciliation.reload).to be_processing
    end

    context "when record is invalid" do
      before do
        allow(reconciliation).to receive(:processing!).and_raise(
          ActiveRecord::RecordInvalid.new(reconciliation)
        )
      end

      it "fails with validation error" do
        result = described_class.call(reconciliation:)

        expect(result).to be_failure
        expect(result.error_code).to eq(ErrorCodes::VALIDATION_ERROR)
      end
    end
  end
end
