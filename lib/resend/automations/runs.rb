# frozen_string_literal: true

module Resend
  module Automations
    # Automation Runs api wrapper
    module Runs
      class << self
        # https://resend.com/docs/api-reference/automations/list-automation-runs
        def list(automation_id, params = {})
          base_path = "automations/#{automation_id}/runs"
          path = Resend::PaginationHelper.build_paginated_path(base_path, params)
          Resend::Request.new(path, {}, "get").perform
        end

        # https://resend.com/docs/api-reference/automations/get-automation-run
        def get(automation_id, run_id)
          Resend::Request.new("automations/#{automation_id}/runs/#{run_id}", {}, "get").perform
        end
      end
    end
  end
end
