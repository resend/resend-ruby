# frozen_string_literal: true

module Resend
  # Suppressions API wrapper
  module Suppressions
    class << self
      #
      # Add an email address to the suppression list. Suppressed addresses are
      # skipped by future sends. Adding an address that is already suppressed
      # succeeds and returns the existing suppression.
      #
      # @param params [Hash] the parameters
      # @option params [String] :email the email address to suppress (required).
      #   The API lowercases and trims it.
      #
      # https://resend.com/docs/api-reference/suppressions/add-suppression
      def add(params)
        Resend::Request.new("suppressions", params, "post").perform
      end

      #
      # Retrieve a list of suppressions. Each entry has `id`, `email`, `origin`,
      # `source_id` and `created_at`; unlike `get`, list entries carry no `object` key.
      #
      # @param params [Hash] optional filtering and pagination parameters
      # @option params [String] :origin filter by origin: 'bounce', 'complaint' or 'manual'
      # @option params [Integer] :limit number of results to return (1-100)
      # @option params [String] :after cursor for forward pagination
      # @option params [String] :before cursor for backward pagination
      #
      # https://resend.com/docs/api-reference/suppressions/list-suppressions
      def list(params = {})
        path = Resend::PaginationHelper.build_paginated_path("suppressions", params)
        Resend::Request.new(path, {}, "get").perform
      end

      #
      # Retrieve a single suppression. The API returns 404 'Suppression not found'
      # when the address or ID is not suppressed.
      #
      # @param id_or_email [String] the suppression ID or the suppressed email address (required)
      #
      # https://resend.com/docs/api-reference/suppressions/get-suppression
      def get(id_or_email)
        raise ArgumentError, "Missing required `id_or_email` field" if id_or_email.nil? || id_or_email.empty?

        Resend::Request.new("suppressions/#{ERB::Util.url_encode(id_or_email)}", {}, "get").perform
      end

      #
      # Remove a single suppression, which allows sending to that address again.
      # The API returns 404 'Suppression not found' when the address or ID is not suppressed.
      #
      # @param id_or_email [String] the suppression ID or the suppressed email address (required)
      #
      # https://resend.com/docs/api-reference/suppressions/remove-suppression
      def remove(id_or_email)
        raise ArgumentError, "Missing required `id_or_email` field" if id_or_email.nil? || id_or_email.empty?

        Resend::Request.new("suppressions/#{ERB::Util.url_encode(id_or_email)}", {}, "delete").perform
      end
    end
  end
end
