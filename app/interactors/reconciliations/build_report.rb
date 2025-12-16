# frozen_string_literal: true

module Reconciliations
  class BuildReport
    include Interactor
    include ErrorHandling

    def call
      context.report = ReportBuilder.call(context.match_result)
    end
  end
end
