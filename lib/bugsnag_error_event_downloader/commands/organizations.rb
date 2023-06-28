# frozen_string_literal: true

module BugsnagErrorEventDownloader
  module Commands
    class Organizations
      attr_reader :client

      def initialize
        @client = BugsnagApiClient::Client.new
      end

      def get
        organizations.map do |organization|
          [organization.id, organization.slug].join(",")
        end
      end

      def find_id_by_name!(name)
        id = organizations.find do |organization|
          organization.slug == name
        end&.id 
        raise ValidationError.new(
          message: 'Specify valid name', attributes: ["organization_name"]
        ) unless id
        id
      end

      private

      def organizations
        @organizations ||= client.organizations
      end
    end
  end
end
