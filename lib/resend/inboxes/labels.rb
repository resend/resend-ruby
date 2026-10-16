# frozen_string_literal: true

module Resend
  module Inboxes
    # Inbox Labels api wrapper
    #
    # A label is a named, colored tag that belongs to one inbox.
    module Labels
      class << self
        # Retrieve every label on the inbox, oldest first. The list is not paginated.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID or the inbox email address (required)
        #
        # https://resend.com/docs/api-reference/inboxes/list-labels
        def list(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

          Resend::Request.new("#{Resend::Inboxes.path(params[:inbox_id])}/labels", {}, "get").perform
        end

        # Create a label on an inbox
        #
        # An inbox can have at most 100 labels. Label names are unique per inbox, compared without
        # case. A duplicate name or a full inbox returns a 422 validation_error.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID or the inbox email address (required)
        # @option params [String] :name the name of the label, max 64 characters (required)
        # @option params [String] :color the color of the label, as a `#RRGGBB` hex color. It is stored
        #   in uppercase. When omitted, a random color from the dashboard palette is used
        #
        # @return [Hash] the created label `object` and `id`
        #
        # https://resend.com/docs/api-reference/inboxes/create-label
        def create(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?

          path = "#{Resend::Inboxes.path(params[:inbox_id])}/labels"
          Resend::Request.new(path, params.except(:inbox_id), "post").perform
        end

        # Update an existing inbox label
        #
        # Renames or recolors a label. Omitted fields keep their current value. A new name must not
        # match another label on the inbox, compared without case, or the request returns a 422
        # validation_error.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID or the inbox email address (required)
        # @option params [String] :label_id the label ID (required)
        # @option params [String] :name a new name for the label, max 64 characters
        # @option params [String] :color a new color for the label, as a `#RRGGBB` hex color.
        #   It is stored in uppercase
        #
        # https://resend.com/docs/api-reference/inboxes/update-label
        def update(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?
          raise ArgumentError, "label_id is required" if params[:label_id].nil?

          path = "#{Resend::Inboxes.path(params[:inbox_id])}/labels/#{params[:label_id]}"
          Resend::Request.new(path, params.except(:inbox_id, :label_id), "patch").perform
        end

        # Remove an existing inbox label
        #
        # Deletes the label and removes it from every thread that carries it.
        #
        # @param params [Hash] the parameters
        # @option params [String] :inbox_id the inbox ID or the inbox email address (required)
        # @option params [String] :label_id the label ID (required)
        #
        # https://resend.com/docs/api-reference/inboxes/delete-label
        def remove(params = {})
          raise ArgumentError, "inbox_id is required" if params[:inbox_id].nil?
          raise ArgumentError, "label_id is required" if params[:label_id].nil?

          path = "#{Resend::Inboxes.path(params[:inbox_id])}/labels/#{params[:label_id]}"
          Resend::Request.new(path, {}, "delete").perform
        end
      end
    end
  end
end
