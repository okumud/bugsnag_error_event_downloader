# frozen_string_literal: true

module BugsnagErrorEventDownloader
  class Exit
    class << self
      def run(status:)
        exit(status)
      end
    end
  end
end
