# frozen_string_literal: true

# Matches transactions from bank and processor files
class TransactionMatcher
  AMOUNT_TOLERANCE = BigDecimal("0.01") # Allow 1 cent variance for rounding

  Result = Struct.new(:matched, :bank_only, :processor_only, :discrepancies, keyword_init: true)

  def self.call(bank_transactions:, processor_transactions:)
    new(bank_transactions, processor_transactions).call
  end

  def initialize(bank_transactions, processor_transactions)
    @bank_transactions = bank_transactions
    @processor_transactions = processor_transactions
    @results = { matched: [], bank_only: [], processor_only: [], discrepancies: [] }
  end

  def call
    match_transactions
    build_result
  end

  private

  def match_transactions
    processor_by_id = @processor_transactions.index_by { |tx| tx[:id] }

    @bank_transactions.each do |bank_tx|
      processor_tx = processor_by_id.delete(bank_tx[:id])
      classify_transaction(bank_tx, processor_tx)
    end

    # Remaining processor transactions are processor-only
    @results[:processor_only] = processor_by_id.values
  end

  def classify_transaction(bank_tx, processor_tx)
    return @results[:bank_only] << bank_tx unless processor_tx

    if amounts_match?(bank_tx[:amount], processor_tx[:amount])
      @results[:matched] << { bank: bank_tx, processor: processor_tx }
    else
      @results[:discrepancies] << build_discrepancy(bank_tx, processor_tx)
    end
  end

  def build_discrepancy(bank_tx, processor_tx)
    {
      id: bank_tx[:id],
      bank_amount: bank_tx[:amount],
      processor_amount: processor_tx[:amount],
      difference: (bank_tx[:amount] - processor_tx[:amount]).abs
    }
  end

  def build_result
    Result.new(**@results)
  end

  def amounts_match?(bank_amount, processor_amount)
    (bank_amount - processor_amount).abs <= AMOUNT_TOLERANCE
  end
end
