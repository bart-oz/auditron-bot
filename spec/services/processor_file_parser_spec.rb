# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProcessorFileParser do
  describe ".call" do
    context "with valid JSON file" do
      let(:file_mock) do
        content = Rails.root.join("spec/fixtures/files/processor_transactions.json").read
        mock = double("file")
        allow(mock).to receive_messages(attached?: true, download: content)
        mock
      end

      it "parses transactions from JSON" do
        result = described_class.call(file_mock)

        expect(result).to be_an(Array)
        expect(result.size).to eq(4)
      end

      it "normalizes transaction data" do
        result = described_class.call(file_mock)
        first_tx = result.first

        expect(first_tx[:id]).to eq("TX001")
        expect(first_tx[:amount]).to eq(BigDecimal("100.00"))
        expect(first_tx[:date]).to eq(Date.new(2023, 4, 1))
        expect(first_tx[:description]).to eq("Payment One")
        expect(first_tx[:status]).to eq("completed") # normalized from "successful"
      end

      it "converts cents to dollars" do
        result = described_class.call(file_mock)

        expect(result[1][:amount]).to eq(BigDecimal("250.50")) # 25050 cents
        expect(result[2][:amount]).to eq(BigDecimal("75.00"))  # 7500 cents
      end
    end

    context "with different statuses" do
      let(:file_mock) do
        json_data = {
          transactions: [
            { id: "T1", timestamp: "2023-04-01T10:00:00Z", amount_cents: 100, merchant: "A", status: "successful" },
            { id: "T2", timestamp: "2023-04-01T10:00:00Z", amount_cents: 100, merchant: "B", status: "processing" },
            { id: "T3", timestamp: "2023-04-01T10:00:00Z", amount_cents: 100, merchant: "C", status: "error" }
          ]
        }

        mock = double("file")
        allow(mock).to receive_messages(attached?: true, download: json_data.to_json)
        mock
      end

      it "normalizes status values" do
        result = described_class.call(file_mock)

        expect(result[0][:status]).to eq("completed")
        expect(result[1][:status]).to eq("pending")
        expect(result[2][:status]).to eq("failed")
      end
    end

    context "with no file attached" do
      let(:file_mock) do
        mock = double("file")
        allow(mock).to receive(:attached?).and_return(false)
        mock
      end

      it "raises ParseError" do
        expect do
          described_class.call(file_mock)
        end.to raise_error(ProcessorFileParser::ParseError, "No file attached")
      end
    end

    context "with invalid JSON" do
      let(:file_mock) do
        mock = double("file")
        allow(mock).to receive_messages(attached?: true, download: "{ invalid json }")
        mock
      end

      it "raises ParseError with details" do
        expect do
          described_class.call(file_mock)
        end.to raise_error(ProcessorFileParser::ParseError, /Invalid JSON format/)
      end
    end
  end
end
