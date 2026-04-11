# frozen_string_literal: true

module Resend
  # events api wrapper
  module Events
    class << self
      # https://resend.com/docs/api-reference/events/create-event
      def create(params = {})
        Resend::Request.new("events", params, "post").perform
      end

      # https://resend.com/docs/api-reference/events/get-event
      # identifier can be a UUID or an event name (e.g. "user.signed_up")
      def get(identifier = "")
        path = "events/#{CGI.escape(identifier.to_s)}"
        Resend::Request.new(path, {}, "get").perform
      end

      # https://resend.com/docs/api-reference/events/update-event
      def update(params = {})
        identifier = params[:identifier]
        path = "events/#{CGI.escape(identifier.to_s)}"
        payload = params.reject { |k, _| k == :identifier }
        Resend::Request.new(path, payload, "patch").perform
      end

      # https://resend.com/docs/api-reference/events/delete-event
      # identifier can be a UUID or an event name (e.g. "user.signed_up")
      def remove(identifier = "")
        path = "events/#{CGI.escape(identifier.to_s)}"
        Resend::Request.new(path, {}, "delete").perform
      end

      # https://resend.com/docs/api-reference/events/send-event
      def send(params = {})
        Resend::Request.new("events/send", params, "post").perform
      end

      # https://resend.com/docs/api-reference/events/list-events
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("events", params)
        Resend::Request.new(path, {}, "get").perform
      end
    end
  end
end
