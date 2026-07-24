# frozen_string_literal: true

module Resend
  module Suppressions
    # Suppressions Batch API wrapper
    module Batch
      class << self
        #
        # Add up to 100 email addresses to the suppression list at once. Addresses that
        # are already suppressed come back with their existing suppression instead of failing.
        #
        # @param params [Hash] the parameters
        # @option params [Array<String>] :emails the email addresses to suppress (required, 1 to 100).
        #   The API lowercases and trims them.
        #
        # https://resend.com/docs/api-reference/suppressions/add-suppressions
        def add(params)
          Resend::Request.new("suppressions/batch/add", params, "post").perform
        end

        #
        # Remove up to 100 suppressions at once, either by email address or by
        # suppression ID. Provide exactly one of `emails` or `ids`.
        #
        # @param params [Hash] the parameters
        # @option params [Array<String>] :emails the email addresses to remove (1 to 100)
        # @option params [Array<String>] :ids the suppression IDs to remove (1 to 100), as UUIDs
        #
        # https://resend.com/docs/api-reference/suppressions/remove-suppressions
        def remove(params)
          emails = params[:emails]
          ids = params[:ids]
          raise ArgumentError, "Provide either `emails` or `ids`, but not both" if emails.nil? == ids.nil?

          # The API rejects a null `emails`/`ids`, so the unused key is omitted rather than sent as nil.
          body = emails.nil? ? { ids: ids } : { emails: emails }
          Resend::Request.new("suppressions/batch/remove", body, "post").perform
        end
      end
    end
  end
end
