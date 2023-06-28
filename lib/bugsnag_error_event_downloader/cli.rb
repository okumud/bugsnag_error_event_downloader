# frozen_string_literal: true

module BugsnagErrorEventDownloader
  class CLI < Thor
    class_option :token,
      aliases: ["-t"],
      banner: "BUGSNAG_PARSONAL_ACCESS_TOKEN",
      type: :string,
      desc: "Path to the BUGSNAG_PERSONAL_AUTH_TOKEN with -t, "\
        "or set environment variable to BUGSNAG_PERSONAL_AUTH_TOKEN."

    desc("organizations", "Show organizations.")
    def organizations
      Output.puts Commands::Organizations.new.get
    rescue BugsnagErrorEventDownloader::NoAuthTokenError
      puts_error_no_auth_token_error
    rescue Bugsnag::Api::Unauthorized
      puts_error_bugsnag_api_unauthorized
    end

    desc("projects", "Show projects.")
    option :organization_id,
      aliases: ["-o"],
      required: true,
      type: :string,
      desc: "Path to the organization_id"
    def projects
      Output.puts Commands::Projects.new(
        organization_id: options[:organization_id]
      ).get
    rescue BugsnagErrorEventDownloader::NoAuthTokenError
      puts_error_no_auth_token_error
    rescue ValidationError => e
      puts_error_validation_error(e)
    rescue Bugsnag::Api::Unauthorized
      puts_error_bugsnag_api_unauthorized
    rescue Bugsnag::Api::NotFound
      puts_error_bugsnag_api_not_found
    end

    desc("generate_csv_map", "Generate csv map.")
    option :project_id,
      aliases: ["-p"],
      required: false,
      type: :string,
      desc: "Path to the project_id"
    option :error_id,
      aliases: ["-e"],
      required: false,
      type: :string,
      desc: "Path to the error_id"
    option :url,
      aliases: ["-u"],
      required: false,
      type: :string,
      desc: "Bugsnag url to event"
    option :include_stacktrace,
      required: false,
      type: :boolean,
      desc: "Includes stacktrace(default: false, optional: true)",
      default: false
    option :include_breadcrumbs,
      required: false,
      type: :boolean,
      desc: "Includes breadcrumbs(default: false, optional: true)",
      default: false
    def generate_csv_map
      Output.puts Commands::GenerateCsvMap.new(
        **project_identifier,
        include_stacktrace: options[:include_stacktrace],
        include_breadcrumbs: options[:include_breadcrumbs]
      ).generate
    rescue BugsnagErrorEventDownloader::NoAuthTokenError
      puts_error_no_auth_token_error
    rescue ValidationError => e
      puts_error_validation_error(e)
    rescue Bugsnag::Api::Unauthorized
      puts_error_bugsnag_api_unauthorized
    rescue Bugsnag::Api::NotFound
      puts_error_bugsnag_api_not_found
    end

    desc("error_events", "Show error events.")
    option :project_id,
      aliases: ["-p"],
      required: false,
      type: :string,
      desc: "Path to the project_id"
    option :error_id,
      aliases: ["-e"],
      required: false,
      type: :string,
      desc: "Path to the error_id"
    option :url,
      aliases: ["-u"],
      required: false,
      type: :string,
      desc: "Bugsnag url to event"
    option :csv_map_path,
      aliases: ["-c"],
      required: true,
      type: :string,
      desc: "Path to the csv_map_path"
    def error_events
      Output.puts Commands::ErrorEvents.new(
        **project_identifier,
        csv_map_path: options[:csv_map_path]
      ).get
    rescue BugsnagErrorEventDownloader::NoAuthTokenError
      puts_error_no_auth_token_error
    rescue ValidationError => e
      puts_error_validation_error(e)
    rescue Bugsnag::Api::Unauthorized
      puts_error_bugsnag_api_unauthorized
    rescue Bugsnag::Api::NotFound
      puts_error_bugsnag_api_not_found
    rescue Converter::CsvConverter::CsvMapNotFound
      Output.warn("csv_map not found.")
      Exit.run(status: 1)
    rescue Converter::CsvConverter::JSONInCsvMapIsInvalid
      Output.warn("JSON in csv_map is invalid.")
      Exit.run(status: 1)
    end

    no_commands do
      class << self
        def exit_on_failure?
          true
        end
      end
    end

    private

    def puts_error_no_auth_token_error
      message = "Set the environment variable BUGSNAG_PERSONAL_AUTH_TOKEN. "\
        "Or specify Bugsnag's token by specifying -t or -token."
      Output.warn(message)
      Exit.run(status: 1)
    end

    def puts_error_validation_error(error)
      Output.warn("You need specify '#{error.attributes.join(", ")}'. See -h or --help.")
      Exit.run(status: 1)
    end

    def puts_error_bugsnag_api_unauthorized
      Output.warn("Request denied because you do not have authorization.")
      Exit.run(status: 1)
    end

    def puts_error_bugsnag_api_not_found
      Output.warn("Resource not found in Bugsnag.")
      Exit.run(status: 1)
    end

    def project_identifier
      if options[:url].nil?
        project_identifier_from_parameter
      else
        project_identifier_from_bugsnag_url(options[:url])
      end
    end

    def project_identifier_from_parameter
      raise ValidationError.new(
        message: 'Specify project_id or error_id',
        attributes: ["project_id", "error_id"]
      ) if options[:project_id].nil? || options[:error_id].nil?
      {
        project_id: options[:project_id],
        error_id: options[:error_id],
      }
    end

    def project_identifier_from_bugsnag_url(url)
      # scheme, userinfo, host, port, registry, path, opaque, query, fragment
      _, organization_name, project_name, _, error_id = URI.parse(url).path.split('/')
      {
        project_id: find_project_id(find_organization_id(organization_name), project_name),
        error_id: error_id,
      }
    end

    def find_organization_id(organization_name)
      Commands::Organizations.new.find_id_by_name!(organization_name)
    rescue ValidationError 
      raise ValidationError.new(message: 'Specify valid bugsnag url',attributes: ["url"])
    end

    def find_project_id(organization_id, project_name)
      Commands::Projects.new(organization_id: organization_id)
        .find_id_by_name!(project_name)
    rescue ValidationError 
      raise ValidationError.new(message: 'Specify valid bugsnag url',attributes: ["url"])
    end
  end
end
