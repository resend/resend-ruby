# frozen_string_literal: true

module Resend
  module Inboxes
    # Inbox Agent api wrapper
    module Agent
      class << self
        # Retrieve the agent settings for an inbox
        #
        # An inbox without a configured agent returns empty settings: `instructions` and `tone`
        # are nil and `actions` is an empty array.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID or the inbox email address (required)
        #
        # https://resend.com/docs/api-reference/inboxes/get-agent
        def get(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

          Resend::Request.new("#{Resend::Inboxes.path(params[:inbox_id])}/agent", {}, "get").perform
        end

        # Update the agent settings for an inbox
        #
        # The agent is created when the inbox has none. Omitted fields keep their current value.
        # At least one of `instructions`, `tone`, or `actions` must be provided.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID or the inbox email address (required)
        # @option params [String, nil] :instructions instructions the agent follows when it handles
        #   the threads of the inbox, max 4000 characters. Send nil to clear the instructions
        # @option params [String, nil] :tone the tone the agent writes in. One of `concise_professional`,
        #   `concise_casual`, `expanded_professional`, or `expanded_casual`. Send nil to clear the tone
        # @option params [Array<String>] :actions the actions the agent can take. Replaces the whole set.
        #   Duplicates are removed. Send an empty array to disable all actions. One or more of
        #   `draft_reply`, `forward_thread`, `add_labels`, `assign_thread`, `mark_as_spam`, `archive`,
        #   `move_to_trash`
        #
        # https://resend.com/docs/api-reference/inboxes/update-agent
        def update(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

          path = "#{Resend::Inboxes.path(params[:inbox_id])}/agent"
          Resend::Request.new(path, params.except(:inbox_id), "patch").perform
        end
      end
    end
  end
end
