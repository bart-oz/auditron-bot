# frozen_string_literal: true

require "csv"

# Parses bank transaction CSV files
# Expected format: transaction_id, date, amount, description, status, account_number
class BankFileParser
  ParseError = Class.new(StandardError)

  def self.call(file)
    new(file).call
  end

  def initialize(file)
    @file = file
  end

  def call
    validate_file
    parse_csv
  end

  private

  attr_reader :file

  def validate_file
    raise ParseError, "No file attached" unless file.attached?
  end

  def parse_csv
    content = file.download
    rows = CSV.parse(content, headers: true, header_converters: :symbol)

    rows.map do |row|
      normalize_row(row)
    end
  rescue CSV::MalformedCSVError => e
    raise ParseError, "Invalid CSV format: #{e.message}"
  end

  def normalize_row(row)
    build_normalized_transaction(
      id: row[:transaction_id],
      amount: row[:amount],
      date: row[:date],
      description: row[:description],
      status: row[:status]
    )
  end

  def build_normalized_transaction(id:, amount:, date:, description:, status:)
    {
      id: id&.strip,
      amount: parse_amount(amount),
      date: parse_date(date),
      description: description&.strip,
      status: status&.strip&.downcase
    }
  end

  def parse_amount(value)
    return BigDecimal("0") if value.blank?

    BigDecimal(value.to_s.gsub(/[^\d.-]/, ""))
  end

  def parse_date(value)
    return nil if value.blank?

    Date.strptime(value.strip, "%d/%m/%Y")
  rescue Date::Error
    # Try alternative format
    Date.parse(value.strip)
  end
end
