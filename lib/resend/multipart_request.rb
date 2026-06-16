# frozen_string_literal: true

require "stringio"

module Resend
  # Handles multipart/form-data requests (file uploads).
  # Extends Request by overriding the request options to use multipart encoding
  # instead of JSON. The file field must be provided as a String (bytes) or IO object.
  class MultipartRequest < Request
    private

    def build_request_options
      file_data = @body[:file]

      # Wrap raw bytes/string in StringIO so HTTParty can stream the content
      file_io = if file_data.respond_to?(:read)
                  file_data
                else
                  StringIO.new(file_data.b)
                end

      body = { file: file_io }
      body[:column_map] = serialize_json(@body[:column_map]) if @body[:column_map]
      body[:on_conflict] = @body[:on_conflict] if @body[:on_conflict]
      body[:segments] = serialize_json(@body[:segments]) if @body[:segments]

      # HTTParty sets Content-Type automatically when multipart: true is set.
      # Remove the application/json Content-Type so it doesn't conflict.
      multipart_headers = @headers.reject { |k, _| k == "Content-Type" }

      { headers: multipart_headers, body: body, multipart: true }
    end

    def serialize_json(value)
      return value if value.is_a?(String)

      value.to_json
    end
  end
end
