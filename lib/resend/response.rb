# frozen_string_literal: true

module Resend
  # Response wrapper that maintains backwards compatibility while exposing headers
  #
  # This class wraps API responses and behaves like a Hash for backwards compatibility,
  # while also providing access to response headers via the #headers method.
  #
  # @example Backwards compatible hash access
  #   response = Resend::Emails.send(params)
  #   response[:id]  # => "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
  #
  # @example Accessing response headers
  #   response = Resend::Emails.send(params)
  #   response.headers  # => {"content-type" => "application/json", ...}
  #   response.headers['x-ratelimit-remaining']  # => "50"
  class Response
    include Enumerable

    # @param data [Hash] The response data
    # @param headers [Hash, HTTParty::Response] The response headers
    def initialize(data, headers)
      @data = data.is_a?(Hash) ? data : {}
      @headers = normalize_headers(headers)
    end

    # Access response headers
    # @return [Hash] Response headers as a hash with lowercase string keys
    def headers
      @headers
    end

    # Hash-like access via []
    # @param key [Symbol, String] The key to access
    # @return [Object] The value at the key
    def [](key)
      @data[key]
    end

    # Hash-like assignment via []=
    # @param key [Symbol, String] The key to set
    # @param value [Object] The value to set
    def []=(key, value)
      @data[key] = value
    end

    # Dig into nested hash structure
    # @param keys [Array<Symbol, String>] Keys to dig through
    # @return [Object] The value at the nested key path
    def dig(*keys)
      @data.dig(*keys)
    end

    # Convert to plain hash
    # @return [Hash] The underlying data hash
    def to_h
      @data
    end

    alias_method :to_hash, :to_h

    # Get all keys from the data
    # @return [Array] Array of keys
    def keys
      @data.keys
    end

    # Get all values from the data
    # @return [Array] Array of values
    def values
      @data.values
    end

    # Check if key exists
    # @param key [Symbol, String] The key to check
    # @return [Boolean] True if key exists
    def key?(key)
      @data.key?(key)
    end

    alias_method :has_key?, :key?

    # Enable enumeration over the data
    def each(&block)
      @data.each(&block)
    end

    # Transform keys in the underlying data
    # @return [Resend::Response] Self for chaining
    def transform_keys!(&block)
      @data.transform_keys!(&block)
      self
    end

    # Check if response is empty
    # @return [Boolean] True if data is empty
    def empty?
      @data.empty?
    end

    # Respond to hash-like methods
    def respond_to_missing?(method_name, include_private = false)
      @data.respond_to?(method_name) || super
    end

    # Delegate unknown methods to the underlying data hash
    def method_missing(method_name, *args, &block)
      if @data.respond_to?(method_name)
        result = @data.send(method_name, *args, &block)
        # If the method returns the hash itself, return self to maintain wrapper
        result.equal?(@data) ? self : result
      else
        super
      end
    end

    # String representation for debugging
    # @return [String] String representation of the response
    def inspect
      "#<Resend::Response data=#{@data.inspect} headers=#{@headers.keys.inspect}>"
    end

    private

    # Normalize headers to a simple hash with lowercase string keys
    # @param headers [Hash, HTTParty::Response, nil] The headers to normalize
    # @return [Hash] Normalized headers hash
    def normalize_headers(headers)
      return {} if headers.nil?

      # Handle HTTParty::Response object
      if headers.respond_to?(:headers)
        headers = headers.headers
      end

      # Convert to hash and normalize keys to lowercase strings
      case headers
      when Hash
        headers.to_h.transform_keys { |k| k.to_s.downcase }
      else
        {}
      end
    end
  end
end
