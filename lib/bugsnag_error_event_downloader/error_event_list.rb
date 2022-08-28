# frozen_string_literal: true

module BugsnagErrorEventDownloader
  class ErrorEventList
    def initialize
      errors = []
      begin
        @client = BugsnagApiClient::ErrorEventClient.new
      rescue ValidationError => e
        errors << e.attributes
      end
      begin
        @csv_converter = Converter::CsvConverter.new
      rescue ValidationError => e
        errors << e.attributes
      end
      raise ValidationError.new(attributes: errors.flatten) unless errors.empty?
    end

    attr_reader :client, :csv_converter

    def get
      events = client.fetch_all
      csv_converter.convert(events)
    end
  end
end
