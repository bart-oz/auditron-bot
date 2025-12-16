# frozen_string_literal: true

module Reconciliations
  class ParseProcessorFile
    include Interactor
    include ErrorHandling

    def call
      context.processor_transactions = ProcessorFileParser.call(context.reconciliation.processor_file)
    rescue ProcessorFileParser::ParseError => e
      fail_with!(ErrorCodes::VALIDATION_ERROR, message: "Processor file parsing failed: #{e.message}")
    end
  end
end
