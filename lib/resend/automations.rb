# frozen_string_literal: true

module Resend
  # automations api wrapper
  module Automations
    class << self
      # https://resend.com/docs/api-reference/automations/create-automation
      def create(params = {})
        Resend::Request.new("automations", params, "post").perform
      end

      # https://resend.com/docs/api-reference/automations/get-automation
      def get(automation_id = "")
        Resend::Request.new("automations/#{automation_id}", {}, "get").perform
      end

      # https://resend.com/docs/api-reference/automations/update-automation
      def update(params = {})
        path = "automations/#{params[:automation_id]}"
        payload = params.reject { |k, _| k == :automation_id }
        Resend::Request.new(path, payload, "patch").perform
      end

      # https://resend.com/docs/api-reference/automations/delete-automation
      def remove(automation_id = "")
        Resend::Request.new("automations/#{automation_id}", {}, "delete").perform
      end

      # https://resend.com/docs/api-reference/automations/stop-automation
      def stop(automation_id = "")
        Resend::Request.new("automations/#{automation_id}/stop", {}, "post").perform
      end

      # https://resend.com/docs/api-reference/automations/list-automations
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("automations", params)
        Resend::Request.new(path, {}, "get").perform
      end
    end
  end
end
