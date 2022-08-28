# frozen_string_literal: true

require "forwardable"

module BugsnagErrorEventDownloader
  module BugsnagApiClient
    class Client
      extend Forwardable

      def initialize
        unless ENV["BUGSNAG_PERSONAL_AUTH_TOKEN"].nil?
          @client = Bugsnag::Api::Client.new(auth_token: ENV["BUGSNAG_PERSONAL_AUTH_TOKEN"])
          return
        end

        option = Option.new
        if option.has?(:token)
          @client = Bugsnag::Api::Client.new(auth_token: option.get(:token))
          return
        end

        raise NoAuthTokenError
      end

      attr_reader :client

      def_delegators(:client, :organizations, :projects, :error_events, :last_response)
    end
  end
end
