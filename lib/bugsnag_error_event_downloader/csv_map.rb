# frozen_string_literal: true

module BugsnagErrorEventDownloader
  class CsvMap
    def initialize
      option = Option.new
      errors = []
      errors << "project_id" unless option.get(:project_id)
      errors << "error_id" unless option.get(:error_id)
      raise ValidationError.new(attributes: errors) unless errors.empty?

      @client = BugsnagApiClient::ErrorEventClient.new
      @include_stacktrace = option.get(:include_stacktrace)
      @include_breadcrumbs = option.get(:include_breadcrumbs)
    end

    attr_reader :client, :include_stacktrace, :include_breadcrumbs

    def generate
      events = client.fetch_first
      json_paths = extract_json_paths(events)
      json_paths = reject_stacktrace(json_paths) unless include_stacktrace
      json_paths = reject_breadcrumbs(json_paths) unless include_breadcrumbs
      csv_map = generate_csv_map(json_paths)
      csv_map.to_json
    end

    private

    def extract_json_paths(events)
      json_paths = []
      events.each do |event|
        json = JSON.parse(event.to_h.to_json)
        json_path = JsonPath.fetch_all_path(json)
        json_paths.concat(json_path)
      end
      json_paths.uniq
    end

    def reject_stacktrace(json_paths)
      json_paths.reject do |json_path|
        json_path.include?("stacktrace")
      end
    end

    def reject_breadcrumbs(json_paths)
      json_paths.reject do |json_path|
        json_path.include?("breadcrumbs")
      end
    end

    def generate_csv_map(json_paths)
      json_paths[1..].map { |path| { header: path, path: path } }
    end
  end
end
