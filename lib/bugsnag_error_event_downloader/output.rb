# frozen_string_literal: true

module BugsnagErrorEventDownloader
  class Output
    class << self
      def puts(message)
        Kernel.puts message
      end

      def warn(message)
        Kernel.warn(message)
      end
    end
  end
end
