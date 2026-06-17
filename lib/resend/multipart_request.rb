# frozen_string_literal: true

require "securerandom"

module Resend
  # Handles multipart/form-data requests (file uploads).
  # Builds the multipart body directly instead of relying on HTTParty's
  # duck-typing file detection, which requires a :path method.
  class MultipartRequest < Request
    NEWLINE = "\r\n"
    private_constant :NEWLINE

    private

    def build_request_options
      boundary = SecureRandom.hex(16)
      headers = @headers.merge("Content-Type" => "multipart/form-data; boundary=#{boundary}")
      { headers: headers, body: build_multipart_body(boundary) }
    end

    def build_multipart_body(boundary)
      body = "".b

      body << part(boundary, "file", read_file(@body[:file]), filename: "import.csv", content_type: "text/csv")
      optional_fields.each { |name, value| body << part(boundary, name, value) }
      body << "--#{boundary}--#{NEWLINE}".b

      body
    end

    def part(boundary, name, value, filename: nil, content_type: nil)
      disposition = %(Content-Disposition: form-data; name="#{name}")
      disposition += %(; filename="#{filename}") if filename

      header = "--#{boundary}#{NEWLINE}#{disposition}#{NEWLINE}"
      header += "Content-Type: #{content_type}#{NEWLINE}" if content_type
      header += NEWLINE

      header.b + value.to_s.b + NEWLINE.b
    end

    def read_file(file_data)
      if file_data.respond_to?(:read)
        content = file_data.read
        file_data.rewind if file_data.respond_to?(:rewind)
        content.b
      else
        file_data.to_s.b
      end
    end

    def optional_fields
      {
        column_map: @body[:column_map] && serialize_json(@body[:column_map]),
        on_conflict: @body[:on_conflict],
        segments: @body[:segments] && serialize_json(@body[:segments]),
        topics: @body[:topics] && serialize_json(@body[:topics])
      }.compact
    end

    def serialize_json(value)
      return value if value.is_a?(String)

      value.to_json
    end
  end
end
