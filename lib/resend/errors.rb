# frozen_string_literal: true

module Resend
  class ResendError < StandardError
  end

  class InvalidPermissionError < ResendError
  end
end
