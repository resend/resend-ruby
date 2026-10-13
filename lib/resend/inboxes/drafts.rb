# frozen_string_literal: true

module Resend
  module Inboxes
    # Inbox Drafts api wrapper
    module Drafts
      class << self
        # Retrieve a list of drafts, most recently updated first
        #
        # Returns the unsent drafts on the inbox. The `after` and `before` cursors take a draft ID from
        # the current page. A cursor that is not an unsent draft on this inbox returns a 404.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [Integer] :limit the maximum number of results to return
        # @option params [String] :after the cursor for pagination
        # @option params [String] :before the cursor for pagination
        #
        # https://resend.com/docs/api-reference/inboxes/list-drafts
        def list(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

          path = Resend::PaginationHelper.build_paginated_path(drafts_path(params), params.except(:inbox_id))
          Resend::Request.new(path, {}, "get").perform
        end

        # Create a draft
        #
        # Creates an unsent draft on the inbox. Omit `thread_id` and `reply_to_email_id` for a draft
        # that starts a new thread. Pass both together for a reply draft in an existing thread. A reply
        # draft without `to` is addressed to the sender of the email it replies to, or to its Reply-To
        # when set. For an email the inbox sent, it defaults to that email's `to` recipients. Send
        # `to: []` to leave it empty. At least one of `to`, `cc`, `bcc`, `subject`, `text`, `html` or
        # `attachments` must be non-empty. The combined recipients of `to`, `cc` and `bcc` cannot exceed
        # 50. Only one unsent reply draft can target an email, so a reply draft request for an email
        # that already has one returns the ID of the existing draft. That request ignores every other
        # field, except `attachments`, which replaces the attachments of the existing draft when sent.
        # A reply draft created without `subject` stores an empty subject and gets no `Re:` prefix,
        # so set one before you send it.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [String, Array<String>] :to the recipients. Each value can include a friendly
        #   name, for example `Ada Lovelace <ada@example.org>`
        # @option params [String, Array<String>] :cc the CC recipients
        # @option params [String, Array<String>] :bcc the BCC recipients
        # @option params [String] :subject the subject, max 2000 characters
        # @option params [String] :html the HTML body
        # @option params [String] :text the plain text body
        # @option params [String] :thread_id the thread ID to reply in. Must be sent with `reply_to_email_id`
        # @option params [String] :reply_to_email_id the email ID to reply to. Must be sent with `thread_id`
        # @option params [Array<Hash>] :attachments files to store on the draft. Each one needs `content`,
        #   `filename` and `content_type`. A `path` or `content_id` returns a 422. The files on a draft can
        #   total at most 25 MB. An empty file or a blocked file type returns a 422
        # @param options [Hash] additional options for the request
        # @option options [String] :idempotency_key a unique key for the request, so the draft is created
        #   only once. 1 to 256 characters. A retry with the same key within 24 hours returns the first
        #   response, with the `idempotent-replayed: true` header. Reusing the key with a different body,
        #   or while the first request is still running, returns a 409
        #
        # @return [Hash] the draft `object` and `id`
        #
        # https://resend.com/docs/api-reference/inboxes/create-draft
        def create(params = {}, options: {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

          Resend::Request.new(drafts_path(params), params.except(:inbox_id), "post", options: options).perform
        end

        # Retrieve a single draft
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [String] :draft_id the draft ID (required)
        #
        # https://resend.com/docs/api-reference/inboxes/get-draft
        def get(params = {})
          validate_draft!(params)

          Resend::Request.new(draft_path(params), {}, "get").perform
        end

        # Update an existing draft
        #
        # Updates the content of an unsent draft. Omitted fields are left unchanged. Send at least one
        # of `to`, `cc`, `bcc`, `subject`, `text`, `html` or `attachments`. Sending `attachments` replaces
        # every attachment on the draft. A request that sets `text` or `html` replaces the whole body.
        # The body part you omit from that request becomes nil. The merged draft must still contain at
        # least one non-empty field, and its combined recipients cannot exceed 50. A draft that was
        # already sent, or that changed during the request, returns a 409.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [String] :draft_id the draft ID (required)
        # @option params [String, Array<String>, nil] :to the recipients. Pass nil to clear
        # @option params [String, Array<String>, nil] :cc the CC recipients. Pass nil or [] to clear
        # @option params [String, Array<String>, nil] :bcc the BCC recipients. Pass nil or [] to clear
        # @option params [String, nil] :subject the subject, max 2000 characters. Pass nil to clear
        # @option params [String, nil] :html the HTML body. Pass nil to clear
        # @option params [String, nil] :text the plain text body. Pass nil to clear
        # @option params [Array<Hash>] :attachments files to store on the draft, as in {create}. Sending
        #   the field replaces every attachment on the draft. Send [] to remove them all
        #
        # https://resend.com/docs/api-reference/inboxes/update-draft
        def update(params = {})
          validate_draft!(params)

          Resend::Request.new(draft_path(params), params.except(:inbox_id, :draft_id), "patch").perform
        end

        # Remove an existing draft
        #
        # Discards an unsent draft. A draft that was already sent, or that changed during the request,
        # returns a 409.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [String] :draft_id the draft ID (required)
        #
        # https://resend.com/docs/api-reference/inboxes/delete-draft
        def remove(params = {})
          validate_draft!(params)

          Resend::Request.new(draft_path(params), {}, "delete").perform
        end

        # Send a draft
        #
        # Sends the draft from the inbox address. A reply draft is sent in its thread. A draft without
        # a thread starts a new thread. The draft must have at least one `to` recipient, a non-empty
        # `subject`, and `html` or `text`, or the request returns a 422. A draft that was already sent
        # returns a 409. The request body is optional and takes only `headers`.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID. An email address is not accepted (required)
        # @option params [String] :draft_id the draft ID (required)
        # @option params [Hash{String => String}] :headers custom headers to add to the email. The
        #   `In-Reply-To`, `References` and `Reply-To` headers are set by Resend and cannot be set here.
        #   Sending one of them, in any letter case, returns a 422
        # @param options [Hash] additional options for the request
        # @option options [String] :idempotency_key a unique key for the request, so the draft is sent
        #   only once. 1 to 256 characters. A retry with the same key within 24 hours returns the first
        #   response, with the `idempotent-replayed: true` header. Reusing the key with a different body,
        #   or while the first request is still running, returns a 409
        #
        # @return [Hash] the `id` of the sent email
        #
        # https://resend.com/docs/api-reference/inboxes/send-draft
        def send(params = {}, options: {})
          validate_draft!(params)

          body = params.except(:inbox_id, :draft_id)
          Resend::Request.new("#{draft_path(params)}/send", body, "post", options: options).perform
        end

        private

        def validate_draft!(params)
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?
          raise ArgumentError, "draft_id is required" if params[:draft_id].nil?
        end

        def drafts_path(params)
          "inboxes/#{params[:inbox_id]}/drafts"
        end

        def draft_path(params)
          "#{drafts_path(params)}/#{params[:draft_id]}"
        end
      end
    end
  end
end
