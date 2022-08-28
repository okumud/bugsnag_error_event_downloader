# frozen_string_literal: true

require "forwardable"

module BugsnagErrorEventDownloader
  module BugsnagApiClient
    class ErrorEventClient
      def initialize
        @client = Client.new

        option = Option.new

        errors = []
        errors << "project_id" unless option.get(:project_id)
        errors << "error_id" unless option.get(:error_id)
        raise ValidationError.new(attributes: errors) unless errors.empty?

        @project_id = option.get(:project_id)
        @error_id = option.get(:error_id)
      end

      attr_reader :client, :project_id, :error_id

      def fetch_first
        fetch
      end

      def fetch_all
        events = fetch_first
        events.concat(fetch_subsequent)
      end

      private

      def fetch(base_time: Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"))
        client.error_events(
          project_id,
          error_id,
          base: base_time,
          full_reports: true
        )
      end

      def fetch_subsequent
        events = []
        until client.last_response.rels[:next].nil?
          begin
            base_time = client.last_response.data.last.received_at.strftime("%Y-%m-%dT%H:%M:%SZ")
            error_events = fetch(base_time: base_time)
            events.concat(error_events)
            events.uniq!(&:id)
            puts "Currently #{events.size} events downloaded, in progress..."
          rescue Bugsnag::Api::RateLimitExceeded => e
            # Bugsnag API document --- Rate Limiting
            # https://bugsnagapiv2.docs.apiary.io/#introduction/rate-limiting
            retry_after = e.instance_variable_get(:@response).response_headers["retry-after"].to_i
            puts "RateLimitExceeded Retry-After: #{retry_after} seconds"
            sleep(retry_after)
          end
        end
        events
      end
    end
  end
end
