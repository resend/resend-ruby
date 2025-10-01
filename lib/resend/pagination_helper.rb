# frozen_string_literal: true

module Resend
  # Helper class for building paginated query strings
  class PaginationHelper
    class << self
      # Builds a paginated path with query parameters
      #
      # @param base_path [String] the base API path
      # @param query_params [Hash] optional pagination parameters
      # @option query_params [Integer] :limit Number of items to retrieve (max 100)
      # @option query_params [String] :after ID after which to retrieve more items
      # @option query_params [String] :before ID before which to retrieve more items
      # @return [String] the path with query parameters
      def build_paginated_path(base_path, query_params = nil)
        return base_path if query_params.nil? || query_params.empty?

        # Filter out nil values and convert to string keys
        filtered_params = query_params.compact.transform_keys(&:to_s)

        # Build query string
        query_string = filtered_params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")

        return base_path if query_string.empty?

        "#{base_path}?#{query_string}"
      end
    end
  end
end
