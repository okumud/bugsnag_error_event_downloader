# frozen_string_literal: true

module BugsnagErrorEventDownloader
  class NoAuthTokenError < StandardError; end

  class ValidationError < StandardError
    attr_reader :attributes

    def initialize(message: nil, attributes: [])
      @attributes = attributes
      super(message)
    end
  end
end
