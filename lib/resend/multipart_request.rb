# frozen_string_literal: true

require "stringio"

module Resend
  # Handles multipart/form-data requests (file uploads).
  # Extends Request by overriding the request options to use multipart encoding
  # instead of JSON. The file field must be provided as a String (bytes) or IO object.
  class MultipartRequest < Request
    private

    def build_request_options
      multipart_headers = @headers.reject { |k, _| k == "Content-Type" }
      { headers: multipart_headers, body: build_multipart_body, multipart: true }
    end

    def build_multipart_body
      { file: wrap_file(@body[:file]) }.merge(optional_fields)
    end

    def optional_fields
      {
        column_map: @body[:column_map] && serialize_json(@body[:column_map]),
        on_conflict: @body[:on_conflict],
        segments: @body[:segments] && serialize_json(@body[:segments]),
        topics: @body[:topics] && serialize_json(@body[:topics])
      }.compact
    end

    # Wrap raw bytes/string in StringIO so HTTParty can stream the content
    def wrap_file(file_data)
      file_data.respond_to?(:read) ? file_data : StringIO.new(file_data.b)
    end

    def serialize_json(value)
      return value if value.is_a?(String)

      value.to_json
    end
  end
end
