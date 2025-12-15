# frozen_string_literal: true

require "rails_helper"

RSpec.describe BankFileParser do
  describe ".call" do
    context "with valid CSV file" do
      let(:file_mock) do
        content = Rails.root.join("spec/fixtures/files/bank_transactions.csv").read
        mock = double("file")
        allow(mock).to receive_messages(attached?: true, download: content)
        mock
      end

      it "parses transactions from CSV" do
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
        expect(first_tx[:status]).to eq("completed")
      end

      it "handles different amount formats" do
        result = described_class.call(file_mock)

        expect(result[1][:amount]).to eq(BigDecimal("250.50"))
        expect(result[3][:amount]).to eq(BigDecimal("999.99"))
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
        end.to raise_error(BankFileParser::ParseError, "No file attached")
      end
    end

    context "with malformed CSV" do
      let(:file_mock) do
        mock = double("file")
        allow(mock).to receive_messages(attached?: true, download: "invalid,csv\n\"unclosed quote")
        mock
      end

      it "raises ParseError with details" do
        expect do
          described_class.call(file_mock)
        end.to raise_error(BankFileParser::ParseError, /Invalid CSV format/)
      end
    end
  end
end
