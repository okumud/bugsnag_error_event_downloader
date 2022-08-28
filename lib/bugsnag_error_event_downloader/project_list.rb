# frozen_string_literal: true

module BugsnagErrorEventDownloader
  class ProjectList
    attr_reader :client, :organization_id

    def initialize
      @organization_id = Option.new.get(:organization_id)
      raise ValidationError.new(attributes: ["organization_id"]) unless @organization_id

      @client = BugsnagApiClient::Client.new
    end

    def get
      client.projects(organization_id).map do |project|
        [project.id, project.slug].join(",")
      end
    end
  end
end
