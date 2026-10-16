# frozen_string_literal: true

module Resend
  module Inboxes
    module Threads
      # Inbox Thread Labels api wrapper
      #
      # Changes which labels a thread carries. To create, rename, or delete the labels themselves,
      # use {Resend::Inboxes::Labels}. Every method returns every label on the thread after the change.
      module Labels
        class << self
          # Add labels to an inbox thread
          #
          # Labels already on the thread stay on it. A label ID that is not a label of the inbox returns
          # a 404, and nothing changes. To replace the labels of the thread, use {set}.
          #
          # @param params [Hash] the parameters
          # @option params [String] :inbox_id the inbox ID or the inbox email address (required)
          # @option params [String] :thread_id the thread ID (required)
          # @option params [Array<String>] :labels the IDs of the labels to apply to the thread. Between
          #   1 and 10 IDs, each a label of the inbox (required)
          #
          # https://resend.com/docs/api-reference/inboxes/add-thread-labels
          def add(params = {})
            validate_labels!(params)

            Resend::Request.new(labels_path(params), params.slice(:labels), "post").perform
          end

          # Set the labels of an inbox thread
          #
          # Replaces every label on the thread with the given labels, in one atomic change. The labels
          # themselves are kept. An empty array takes every label off the thread. A label ID that is not
          # a label of the inbox returns a 404, and nothing changes.
          #
          # @param params [Hash] the parameters
          # @option params [String] :inbox_id the inbox ID or the inbox email address (required)
          # @option params [String] :thread_id the thread ID (required)
          # @option params [Array<String>] :labels the IDs of the labels the thread carries after the
          #   change. Up to 100 IDs, each a label of the inbox (required)
          #
          # https://resend.com/docs/api-reference/inboxes/set-thread-labels
          def set(params = {})
            validate_labels!(params)

            Resend::Request.new(labels_path(params), params.slice(:labels), "put").perform
          end

          # Remove a label from an inbox thread
          #
          # The label itself is kept, and stays on every other thread that carries it. A label that is
          # not on the thread returns the current labels. To delete the label, use
          # {Resend::Inboxes::Labels.remove}.
          #
          # @param params [Hash] the parameters
          # @option params [String] :inbox_id the inbox ID or the inbox email address (required)
          # @option params [String] :thread_id the thread ID (required)
          # @option params [String] :label_id the label ID (required)
          #
          # https://resend.com/docs/api-reference/inboxes/remove-thread-label
          def remove(params = {})
            validate_thread!(params)
            raise ArgumentError, "label_id is required" if params[:label_id].nil?

            Resend::Request.new("#{labels_path(params)}/#{params[:label_id]}", {}, "delete").perform
          end

          private

          def validate_thread!(params)
            raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?
            raise ArgumentError, "thread_id is required" if params[:thread_id].nil?
          end

          def validate_labels!(params)
            validate_thread!(params)
            raise ArgumentError, "labels is required" if params[:labels].nil?
          end

          def labels_path(params)
            "#{Resend::Inboxes.path(params[:inbox_id])}/threads/#{params[:thread_id]}/labels"
          end
        end
      end
    end
  end
end
