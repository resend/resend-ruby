# frozen_string_literal: true

module Resend
  module Inboxes
    module Threads
      # Inbox Thread Emails api wrapper
      module Emails
        class << self
          # Retrieve a list of thread emails, oldest first
          #
          # Pass the `id` of the last message as `after` to get the next, newer page. Pass the `id` of
          # the first message as `before` to get the previous, older page. You cannot combine `after`
          # and `before`. A cursor that is not a message of the thread returns a 404.
          #
          # @param params [Hash] the parameters
          # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
          # @option params [String] :thread_id the thread ID (required)
          # @option params [Integer] :limit the maximum number of results to return
          # @option params [String] :after the cursor for pagination
          # @option params [String] :before the cursor for pagination
          #
          # https://resend.com/docs/api-reference/inboxes/list-thread-emails
          def list(params = {})
            validate_thread!(params)

            base_path = "inboxes/#{params[:inbox_id]}/threads/#{params[:thread_id]}/emails"
            path = Resend::PaginationHelper.build_paginated_path(base_path, params.except(:inbox_id, :thread_id))
            Resend::Request.new(path, {}, "get").perform
          end

          # Retrieve a single thread email
          #
          # @param params [Hash] the parameters
          # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
          # @option params [String] :thread_id the thread ID (required)
          # @option params [String] :email_id the email ID, as returned in `data[].id` by {list} (required)
          #
          # https://resend.com/docs/api-reference/inboxes/get-thread-email
          def get(params = {})
            validate_email!(params)

            Resend::Request.new(email_path(params), {}, "get").perform
          end

          # Reply to a thread email
          #
          # Sends a reply from the inbox address right away, with no stored draft. The `to` recipients
          # come from the message you reply to. For a message the inbox received, the reply goes to its
          # `Reply-To` addresses, or to its sender when it has no `Reply-To`. For a message the inbox
          # sent, the reply goes to that message's `to` recipients. Set `reply_all` to also copy the
          # other recipients of the message. At least one of `html` or `text` must contain more than
          # whitespace.
          #
          # @param params [Hash] the parameters
          # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
          # @option params [String] :thread_id the thread ID (required)
          # @option params [String] :email_id the email ID of the message to reply to (required)
          # @option params [String] :html the HTML body of the reply
          # @option params [String] :text the plain-text body of the reply
          # @option params [String] :subject the subject of the reply. When omitted, the thread subject
          #   is used, prefixed with `Re:` if it does not already start with it
          # @option params [String, Array<String>] :cc CC recipients. Without `reply_all`, the reply
          #   copies only these addresses
          # @option params [String, Array<String>] :bcc BCC recipients. BCC recipients of the original
          #   message are never copied
          # @option params [Boolean] :reply_all reply to everyone on the original message. For a message the
          #   inbox received, the reply goes to its `Reply-To` addresses, or to its sender when it has none,
          #   and copies the other addresses of its `To` header and its `cc` recipients in `cc`. For a message
          #   the inbox sent, the reply goes to its `Reply-To` addresses when they are not the inbox address,
          #   otherwise to its `to` recipients, and copies its `cc` recipients. The inbox address is always
          #   excluded, and duplicates are removed. Defaults to false
          # @option params [Array<Hash>] :attachments files to attach, as on {Resend::Emails.send}. Each one
          #   needs `content` or `path`. Up to 10 files and at most 25 MB of `content` in total. An empty file, a
          #   blocked file type, or a `path` that is not an `http` or `https` URL, or that points to
          #   `localhost`, returns a 422
          # @option params [Hash{String => String}] :headers custom headers to add to the email. The
          #   `In-Reply-To`, `References` and `Reply-To` headers are set by Resend and cannot be set here.
          #   Sending one of them, in any letter case, returns a 422. Header names cannot be empty, and
          #   names and values cannot contain line breaks or null characters, or the request returns a 422
          # @param options [Hash] additional options for the request
          # @option options [String] :idempotency_key a unique key for the request, so the reply is sent
          #   only once. 1 to 256 characters. A retry with the same key within 24 hours replays the first
          #   successful (2xx) response, with the `idempotent-replayed: true` header. A failed request is
          #   not stored, so you can retry it with the same key. Reusing the key with a different body, or
          #   while the first request is still running, returns a 409
          #
          # @return [Hash] the `id` of the sent email
          #
          # https://resend.com/docs/api-reference/inboxes/reply-thread-email
          def reply(params = {}, options: {})
            validate_email!(params)

            Resend::Request.new("#{email_path(params)}/reply", body(params), "post", options: options).perform
          end

          # Forward a thread email
          #
          # Forwards a message from the inbox address right away, with no stored draft. The original
          # message is quoted under a forwarded-message banner, below the optional `html` or `text`
          # note. The attachments of the original message are sent with the forward, together with any
          # `attachments` you add. The request fails when they exceed 10 files or 25 MB of `content`
          # in total. An original attachment that was sent from a URL (`path`) cannot be forwarded, and the
          # request returns a 422.
          #
          # @param params [Hash] the parameters
          # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
          # @option params [String] :thread_id the thread ID (required)
          # @option params [String] :email_id the email ID of the message to forward (required)
          # @option params [String, Array<String>] :to the recipients (required). `to`, `cc` and `bcc`
          #   combined cannot exceed 50 recipients
          # @option params [String, Array<String>] :cc CC recipients
          # @option params [String, Array<String>] :bcc BCC recipients
          # @option params [String] :html an HTML note sent above the quoted original
          # @option params [String] :text a plain-text note sent above the quoted original
          # @option params [String] :subject the subject of the forward. When omitted, the thread subject
          #   is used, prefixed with `Fwd:` if it does not already start with it
          # @option params [Array<Hash>] :attachments files to attach, as on {Resend::Emails.send}. Each one
          #   needs `content` or `path`. An empty file, a blocked file type, or a `path` that is not an
          #   `http` or `https` URL, or that points to `localhost`, returns a 422
          # @option params [Hash{String => String}] :headers custom headers to add to the email. The
          #   `In-Reply-To`, `References` and `Reply-To` headers are set by Resend and cannot be set here.
          #   Sending one of them, in any letter case, returns a 422. Header names cannot be empty, and
          #   names and values cannot contain line breaks or null characters, or the request returns a 422
          # @param options [Hash] additional options for the request
          # @option options [String] :idempotency_key a unique key for the request, so the forward is sent
          #   only once. 1 to 256 characters. A retry with the same key within 24 hours replays the first
          #   successful (2xx) response, with the `idempotent-replayed: true` header. A failed request is
          #   not stored, so you can retry it with the same key. Reusing the key with a different body, or
          #   while the first request is still running, returns a 409
          #
          # @return [Hash] the `id` of the sent email
          #
          # https://resend.com/docs/api-reference/inboxes/forward-thread-email
          def forward(params = {}, options: {})
            validate_email!(params)

            Resend::Request.new("#{email_path(params)}/forward", body(params), "post", options: options).perform
          end

          private

          def validate_thread!(params)
            raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?
            raise ArgumentError, "thread_id is required" if params[:thread_id].nil?
          end

          def validate_email!(params)
            validate_thread!(params)
            raise ArgumentError, "email_id is required" if params[:email_id].nil?
          end

          def email_path(params)
            "inboxes/#{params[:inbox_id]}/threads/#{params[:thread_id]}/emails/#{params[:email_id]}"
          end

          def body(params)
            params.except(:inbox_id, :thread_id, :email_id)
          end
        end
      end
    end
  end
end
