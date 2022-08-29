# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "bugsnag/api"
require "csv"
require "json"
require "jsonpath"
require "sorbet-runtime"
require "thor"
begin
  require "pry"
  require "pry-byebug"
rescue LoadError
  # do nothing
end

require_relative "bugsnag_error_event_downloader/cli"
require_relative "bugsnag_error_event_downloader/option"
require_relative "bugsnag_error_event_downloader/errors"
require_relative "bugsnag_error_event_downloader/output"
require_relative "bugsnag_error_event_downloader/exit"
require_relative "bugsnag_error_event_downloader/commands/organizations"
require_relative "bugsnag_error_event_downloader/commands/projects"
require_relative "bugsnag_error_event_downloader/commands/generate_csv_map"
require_relative "bugsnag_error_event_downloader/commands/error_events"
require_relative "bugsnag_error_event_downloader/bugsnag_api_client/client"
require_relative "bugsnag_error_event_downloader/bugsnag_api_client/error_event_client"
require_relative "bugsnag_error_event_downloader/converter/csv_converter"
