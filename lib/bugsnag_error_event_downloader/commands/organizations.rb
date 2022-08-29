# frozen_string_literal: true

module BugsnagErrorEventDownloader
  module Commands
    class Organizations
      attr_reader :client

      def initialize
        @client = BugsnagApiClient::Client.new
      end

      def get
        client.organizations.map do |organization|
          [organization.id, organization.slug].join(",")
        end
      end
    end
  end
end
