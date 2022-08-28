# frozen_string_literal: true

module BugsnagErrorEventDownloader
  module Converter
    class CsvConverter
      class CsvMapNotFound < StandardError; end
      class JSONInCsvMapIsInvalid < StandardError; end

      def initialize
        option = Option.new
        errors = []
        errors << "csv_map_path" unless option.get(:csv_map_path)
        raise ValidationError.new(attributes: errors) unless errors.empty?

        @csv_map = parse_csv_map(option.get(:csv_map_path))
      end

      attr_reader :csv_map

      def convert(events)
        CSV.generate do |rows|
          headers = csv_map.map { |m| m["header"] }
          rows << headers
          events.each do |event|
            paths = csv_map.map { |m| m["path"] }
            row = paths.map do |path|
              json_path = JsonPath.new(path)
              json = event.to_h.to_json
              begin
                json_path.on(json).uniq.join(",")
              rescue ArgumentError
                ""
              end
            end
            rows << row
          end
        end
      end

      private

      def parse_csv_map(path)
        csv_map_file = File.read(path)
        JSON.parse(csv_map_file)
      rescue Errno::ENOENT
        raise CsvMapNotFound
      rescue JSON::ParserError
        raise JSONInCsvMapIsInvalid
      end
    end
  end
end
