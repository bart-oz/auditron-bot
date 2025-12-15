# frozen_string_literal: true

# Parses payment processor JSON files
# Expected format: { "transactions": [{ "id", "timestamp", "amount_cents", "merchant", "status" }] }
class ProcessorFileParser
  ParseError = Class.new(StandardError)

  # Returns array of normalized transaction hashes
  def self.call(file)
    new(file).call
  end

  def initialize(file)
    @file = file
  end

  def call
    validate_file
    parse_json
  end

  private

  attr_reader :file

  def validate_file
    raise ParseError, "No file attached" unless file.attached?
  end

  def parse_json
    content = file.download
    data = JSON.parse(content, symbolize_names: true)

    transactions = data[:transactions] || []
    transactions.map { |tx| normalize_transaction(tx) }
  rescue JSON::ParserError => e
    raise ParseError, "Invalid JSON format: #{e.message}"
  end

  def normalize_transaction(transaction)
    build_normalized_transaction(
      id: transaction[:id],
      amount_cents: transaction[:amount_cents],
      timestamp: transaction[:timestamp],
      merchant: transaction[:merchant],
      status: transaction[:status]
    )
  end

  def build_normalized_transaction(id:, amount_cents:, timestamp:, merchant:, status:)
    {
      id: id&.strip,
      amount: cents_to_dollars(amount_cents),
      date: parse_timestamp(timestamp),
      description: merchant&.strip,
      status: normalize_status(status)
    }
  end

  def cents_to_dollars(cents)
    return BigDecimal("0") if cents.blank?

    BigDecimal(cents.to_s) / 100
  end

  def parse_timestamp(timestamp)
    return nil if timestamp.blank?

    Time.zone.parse(timestamp).to_date
  rescue ArgumentError
    nil
  end

  def normalize_status(status)
    case status&.downcase
    when "successful" then "completed"
    when "processing" then "pending"
    when "error" then "failed"
    else status&.downcase
    end
  end
end
