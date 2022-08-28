# frozen_string_literal: true

module BugsnagErrorEventDownloader
  class CLI
    def run
      case Option.new.subcommand
      when "organizations"
        Output.puts OrganizationList.new.get
      when "projects"
        Output.puts ProjectList.new.get
      when "generate_csv_map"
        Output.puts CsvMap.new.generate
      else
        Output.puts ErrorEventList.new.get
      end
    rescue NoAuthTokenError
      Output.warn(<<~HERE.chomp)
        Set the environment variable BUGSNAG_PERSONAL_AUTH_TOKEN. Or specify Bugsnag's token by specifying -t or -token.
      HERE
      Exit.run(status: 1)
    rescue ValidationError => e
      Output.warn("You need specify '#{e.attributes.join(", ")}'. See -h or --help.")
      Exit.run(status: 1)
    rescue OptionParser::MissingArgument => e
      Output.warn("#{e.message}. See -h or --help.")
      Exit.run(status: 1)
    rescue Bugsnag::Api::Unauthorized
      Output.warn("Request denied because you do not have authorization.")
      Exit.run(status: 1)
    rescue Bugsnag::Api::NotFound
      Output.warn("Resource not found in Bugsnag.")
      Exit.run(status: 1)
    rescue Converter::CsvConverter::CsvMapNotFound
      Output.warn("csv_map not found.")
      Exit.run(status: 1)
    rescue Converter::CsvConverter::JSONInCsvMapIsInvalid
      Output.warn("JSON in csv_map is invalid.")
      Exit.run(status: 1)
    end
  end
end
