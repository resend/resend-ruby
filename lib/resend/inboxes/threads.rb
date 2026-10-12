# frozen_string_literal: true

module Resend
  module Inboxes
    # Inbox Threads api wrapper
    #
    # A thread is a conversation made up of one or more emails.
    module Threads
      class << self
        # Retrieve a list of inbox threads, most recently active first
        #
        # The `after` and `before` cursors take a thread ID, and only one of them can be passed.
        # To find threads by text, sender, recipient, attachment, or date, use {search}.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [Array<String>] :folders the folders to list: `inbox`, `archive`, `spam`, `sent`,
        #   `trash`. A thread is returned when any of its emails is in one of the folders. Defaults to
        #   `inbox`, or to `inbox`, `archive` and `sent` when `labels` is set. `spam` and `trash` are only
        #   included when you name them
        # @option params [Array<String>] :labels label IDs. Returns threads with any of these labels.
        #   Up to 50 IDs
        # @option params [Boolean] :read true returns threads where every email is read. false returns
        #   threads with at least one unread email
        # @option params [Integer] :limit the maximum number of results to return
        # @option params [String] :after the cursor for pagination
        # @option params [String] :before the cursor for pagination
        #
        # https://resend.com/docs/api-reference/inboxes/list-threads
        def list(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

          path = build_query_path("inboxes/#{params[:inbox_id]}/threads", params.except(:inbox_id))
          Resend::Request.new(path, {}, "get").perform
        end

        # Search the threads of an inbox
        #
        # Results are ordered by latest activity, newest first, and paginate like {list}. Search can be
        # up to about a minute behind new emails. Different parameters combine, so a thread must match
        # all of them. `folders`, `labels`, and `read` apply to the thread. `query`, `from`, `to`, `cc`,
        # `bcc`, `has_attachment`, `start_date`, and `end_date` must all match the same email in the
        # thread. When more than 10,000 threads match, search covers the 10,000 with the newest
        # matching email.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [String] :query free text to search for in the subject, body, sender,
        #   recipients, and attachment names. Every word must match. Wrap words in double quotes to
        #   match an exact phrase. Start a word or quoted phrase with `-` to exclude it.
        #   Max 256 characters and 32 words
        # @option params [Array<String>] :from senders. Each value matches part of the sender's address
        #   or name, without case. Returns threads that match any of them. Up to 20 values
        # @option params [Array<String>] :to recipients, matched the same way as `from`. Up to 20 values
        # @option params [Array<String>] :cc CC recipients, matched the same way as `from`. Up to 20 values
        # @option params [Array<String>] :bcc BCC recipients, matched the same way as `from`.
        #   Up to 20 values
        # @option params [Boolean] :has_attachment true matches emails with an attachment. false matches
        #   emails without one
        # @option params [String] :start_date matches emails sent on or after this date. Accepts a date
        #   like `2026-09-01` or an ISO 8601 timestamp, in UTC unless the timestamp has an offset
        # @option params [String] :end_date matches emails sent on or before this date. Same formats as
        #   `start_date`. A date covers that whole day
        # @option params [Array<String>] :folders the folders to search, as in {list}
        # @option params [Array<String>] :labels label IDs, as in {list}
        # @option params [Boolean] :read the read state, as in {list}
        # @option params [Integer] :limit the maximum number of results to return
        # @option params [String] :after the cursor for pagination
        # @option params [String] :before the cursor for pagination
        #
        # https://resend.com/docs/api-reference/inboxes/search-threads
        def search(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

          path = build_query_path("inboxes/#{params[:inbox_id]}/threads/search", params.except(:inbox_id))
          Resend::Request.new(path, {}, "get").perform
        end

        # Retrieve a single inbox thread
        #
        # Returns the thread summary. List the emails in the thread with {Emails.list}.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [String] :thread_id the thread ID (required)
        #
        # https://resend.com/docs/api-reference/inboxes/get-thread
        def get(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?
          raise ArgumentError, "thread_id is required" if params[:thread_id].nil?

          Resend::Request.new("inboxes/#{params[:inbox_id]}/threads/#{params[:thread_id]}", {}, "get").perform
        end

        # Update an existing inbox thread
        #
        # Marks a thread read or unread, moves it to a folder, or adds and removes labels. At least one
        # of `read`, `folder`, `label_id`, `add_label_ids`, or `remove_label_ids` is required. A label ID
        # cannot be both added and removed in the same request. Moving a thread out of `trash` restores
        # it and clears its deletion deadline.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [String] :thread_id the thread ID (required)
        # @option params [Boolean] :read marks every email in the thread read or unread
        # @option params [String] :folder moves the thread to this folder: `inbox`, `archive`, `spam`,
        #   or `trash`. `sent` is assigned automatically and cannot be set
        # @option params [Array<String>] :add_label_ids label IDs to apply to the thread.
        #   Between 1 and 10 IDs
        # @option params [Array<String>] :remove_label_ids label IDs to remove from the thread.
        #   Between 1 and 10 IDs
        # @option params [String] :label_id deprecated. Use `add_label_ids` instead. Applies this label
        #   to the thread, the same as one entry in `add_label_ids`
        #
        # https://resend.com/docs/api-reference/inboxes/update-thread
        def update(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?
          raise ArgumentError, "thread_id is required" if params[:thread_id].nil?

          path = "inboxes/#{params[:inbox_id]}/threads/#{params[:thread_id]}"
          Resend::Request.new(path, params.except(:inbox_id, :thread_id), "patch").perform
        end

        # Remove an existing inbox thread
        #
        # Moves the thread to `trash` and schedules it for deletion in 30 days. This is reversible.
        # To restore the thread, update its `folder` to `inbox`, `archive`, or `spam`, which also clears
        # the deletion deadline.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [String] :thread_id the thread ID (required)
        #
        # https://resend.com/docs/api-reference/inboxes/delete-thread
        def remove(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?
          raise ArgumentError, "thread_id is required" if params[:thread_id].nil?

          Resend::Request.new("inboxes/#{params[:inbox_id]}/threads/#{params[:thread_id]}", {}, "delete").perform
        end

        private

        # The API reads list filters as one comma-separated value and rejects a repeated parameter.
        def build_query_path(base_path, query)
          joined = query.transform_values { |value| value.is_a?(Array) ? value.join(",") : value }
          Resend::PaginationHelper.build_paginated_path(base_path, joined)
        end
      end
    end
  end
end
