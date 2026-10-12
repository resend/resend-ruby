# frozen_string_literal: true

module Resend
  module Inboxes
    # Inbox Agent api wrapper
    module Agent
      class << self
        # Retrieve the agent settings for an inbox
        #
        # An inbox without a configured agent returns empty settings: `instructions` and `tone`
        # are nil and `enabled_actions` is an empty array.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        #
        # https://resend.com/docs/api-reference/inboxes/get-agent
        def get(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

          Resend::Request.new("inboxes/#{params[:inbox_id]}/agent", {}, "get").perform
        end

        # Update the agent settings for an inbox
        #
        # The agent is created when the inbox has none. Omitted fields keep their current value.
        # At least one of `instructions`, `tone`, or `enabled_actions` must be provided.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [String, nil] :instructions instructions the agent follows when it handles
        #   the threads of the inbox, max 4000 characters. Send nil to clear the instructions
        # @option params [String, nil] :tone the tone the agent writes in, such as
        #   `friendly and concise`, max 64 characters. Send nil to clear the tone
        # @option params [Array<String>] :enabled_actions the actions the agent can take. Replaces the
        #   whole set. Send an empty array to disable all actions. One or more of `draft_reply`,
        #   `forward_thread`, `add_labels`, `assign_thread`, `mark_as_spam`, `archive_thread`,
        #   `delete_thread`
        #
        # https://resend.com/docs/api-reference/inboxes/update-agent
        def update(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

          path = "inboxes/#{params[:inbox_id]}/agent"
          Resend::Request.new(path, params.except(:inbox_id), "patch").perform
        end
      end
    end
  end
end
