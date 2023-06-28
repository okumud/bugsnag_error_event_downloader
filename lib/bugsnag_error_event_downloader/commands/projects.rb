# frozen_string_literal: true

module BugsnagErrorEventDownloader
  module Commands
    class Projects
      attr_reader :client, :organization_id

      def initialize(organization_id:)
        @organization_id = Option.new.get(:organization_id)
        raise ValidationError.new(attributes: ["organization_id"]) unless organization_id

        @organization_id = organization_id
        @client = BugsnagApiClient::Client.new
      end

      def get
        projects.map do |project|
          [project.id, project.slug].join(",")
        end
      end

      def find_id_by_name!(name)
        id = projects.find do |project|
          project.slug == name
        end&.id
        raise ValidationError.new(
          message: 'Specify valid bugsnag url',attributes: ["url"]
        ) unless id
        id
      end

      private

      def projects
        @projects ||= client.projects(organization_id)
      end
    end
  end
end
