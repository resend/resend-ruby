# frozen_string_literal: true

require "resend/request"

module Resend
  # api keys api wrapper
  module ApiKeys
    ALLOWED_PERMISSIONS = %w[sending_access full_access].freeze

    # https://resend.com/docs/api-reference/api-keys/create-api-key
    def create_api_key(params)
      validate!(params)
      path = "/api-keys"
      Resend::Request.new(self, path, params, "post").perform
    end

    def validate!(params = {})
      validate_api_key_name!(params)
      validate_api_key_permission!(params)
      validate_api_key_domain!(params)
    end

    # name can not be nil
    # name can not be empty
    def validate_api_key_name!(params)
      raise ArgumentError, "Argument 'name' is required" if params[:name].nil?
      raise ArgumentError, "Argument 'name' can not be blank" if params[:name].empty?
    end

    # permission can be nil
    # permission can not be blank when it is present
    # permission must be included in ALLOWED_PERMISSIONS when it is present
    def validate_api_key_permission!(params)
      return if params[:permission].nil?
      raise ArgumentError, "Argument 'permission' can not be blank" if params[:permission].empty?
      unless ALLOWED_PERMISSIONS.include? params[:permission]
        raise ArgumentError, "#{params[:permission]} is invalid, must be 'full_access' or 'sending_access'"
      end
    end

    # domain can be nil
    # domain can not be blank when present
    def validate_api_key_domain!(params)
      return if params[:domain_id].nil?
      raise ArgumentError, "Argument 'domain_id' can not be blank" if params[:domain_id].empty?
    end
  end
end
