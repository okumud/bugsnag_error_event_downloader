# frozen_string_literal: true

module BugsnagErrorEventDownloader
  class Option
    require "optparse"

    attr_reader :option, :args

    def initialize(args = ARGV)
      @option = {}
      @args = args.dup
      OptionParser.new do |o|
        o.on("-t", "--token TOKEN", "with token option") { |v| @option[:token] = v }
        o.on("--organization_id ORGANIZATION_ID", "organization id") { |v| @option[:organization_id] = v }
        o.on("--project_id PROJECT_ID", "project id") { |v| @option[:project_id] = v }
        o.on("--error_id ERROR_ID", "error id") { |v| @option[:error_id] = v }
        o.on("--csv_map_path CSV_MAP", "csv map") { |v| @option[:csv_map_path] = v }
        o.on("--include_stacktrace", "include stacktrace(optional)") { @option[:include_stacktrace] = true }
        o.on("--include_breadcrumbs", "include breadcrumbs(optional)") { @option[:include_breadcrumbs] = true }
        o.on("-h", "--help", "show this help") do |_v|
          puts o
          exit
        end
        o.parse!(@args)
      end
    end

    def has?(name)
      option.include?(name)
    end

    def get(name)
      option[name]
    end

    def subcommand
      subcommands.first
    end

    private

    def subcommands
      args
    end
  end
end
