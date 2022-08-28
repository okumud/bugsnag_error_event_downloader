# frozen_string_literal: true

RSpec.describe(BugsnagErrorEventDownloader::CLI) do
  let(:instance) { described_class.new }

  before do
    option = instance_double(BugsnagErrorEventDownloader::Option)
    allow(BugsnagErrorEventDownloader::Option).to(receive(:new).and_return(option))
    allow(option).to(receive(:subcommand).and_return(subcommand))

    allow(BugsnagErrorEventDownloader::Output).to(receive(:puts))
    allow(BugsnagErrorEventDownloader::Output).to(receive(:warn))
    allow(BugsnagErrorEventDownloader::Exit).to(receive(:run))
  end

  shared_examples "puts as standard error" do |error_message|
    it "puts '#{error_message}' as standard error" do
      subject
      expect(BugsnagErrorEventDownloader::Output).to(have_received(:warn).with(error_message))
    end
  end

  shared_examples "exit with status 1" do
    it "exits with status 1" do
      subject
      expect(BugsnagErrorEventDownloader::Exit).to(have_received(:run).with(status: 1))
    end
  end

  describe "#run" do
    subject { instance.run }

    context "with 'organizations' subcommand" do
      let(:subcommand) { "organizations" }
      let(:organization_list) { instance_double(BugsnagErrorEventDownloader::OrganizationList) }

      before do
        allow(BugsnagErrorEventDownloader::OrganizationList).to(receive(:new).and_return(organization_list))
      end

      context "when normal case" do
        before do
          allow(organization_list).to(receive(:get).and_return([
            "11111,some-organization1",
            "22222,some-organization2",
          ]))
        end

        it do
          subject
          expect(BugsnagErrorEventDownloader::Output).to(have_received(:puts).with([
            "11111,some-organization1",
            "22222,some-organization2",
          ]))
        end
      end

      context "when no auth token" do
        before do
          allow(BugsnagErrorEventDownloader::OrganizationList)
            .to(receive(:new)
            .and_raise(BugsnagErrorEventDownloader::NoAuthTokenError))
        end

        it_behaves_like "puts as standard error",
          "Set the environment variable BUGSNAG_PERSONAL_AUTH_TOKEN. "\
            "Or specify Bugsnag's token by specifying -t or -token."
        it_behaves_like "exit with status 1"
      end

      context "when no value is specified for an optional argument" do
        before do
          allow(BugsnagErrorEventDownloader::OrganizationList)
            .to(receive(:new)
            .and_raise(OptionParser::MissingArgument.new("-t")))
        end

        it_behaves_like "puts as standard error", "missing argument: -t. See -h or --help."
        it_behaves_like "exit with status 1"
      end

      context "when invalid bugsnag personal auth token is given" do
        before do
          allow(organization_list).to(receive(:get).and_raise(Bugsnag::Api::Unauthorized))
        end

        it_behaves_like "puts as standard error", "Request denied because you do not have authorization."
        it_behaves_like "exit with status 1"
      end
    end

    context "with 'projects' subcommand" do
      let(:subcommand) { "projects" }
      let(:project_list) { instance_double(BugsnagErrorEventDownloader::ProjectList) }

      before do
        allow(BugsnagErrorEventDownloader::ProjectList).to(receive(:new).and_return(project_list))
      end

      context "when normal case" do
        before do
          allow(project_list).to(receive(:get).and_return([
            "11111,example-project1",
            "22222,example-project2",
          ]))
        end

        it do
          subject
          expect(BugsnagErrorEventDownloader::Output).to(have_received(:puts).with([
            "11111,example-project1",
            "22222,example-project2",
          ]))
        end
      end

      context "when no auth token" do
        before do
          allow(BugsnagErrorEventDownloader::ProjectList)
            .to(receive(:new)
            .and_raise(BugsnagErrorEventDownloader::NoAuthTokenError))
        end

        it_behaves_like "puts as standard error",
          "Set the environment variable BUGSNAG_PERSONAL_AUTH_TOKEN. "\
            "Or specify Bugsnag's token by specifying -t or -token."
        it_behaves_like "exit with status 1"
      end

      context "when the `organization_id` parameter is not received" do
        before do
          allow(BugsnagErrorEventDownloader::ProjectList)
            .to(receive(:new)
            .and_raise(BugsnagErrorEventDownloader::ValidationError.new(attributes: ["organization_id"])))
        end

        it_behaves_like "puts as standard error", "You need specify 'organization_id'. See -h or --help."
        it_behaves_like "exit with status 1"
      end

      context "when no value is specified for an optional argument" do
        before do
          allow(BugsnagErrorEventDownloader::ProjectList)
            .to(receive(:new)
            .and_raise(OptionParser::MissingArgument.new("-t")))
        end

        it_behaves_like "puts as standard error", "missing argument: -t. See -h or --help."
        it_behaves_like "exit with status 1"
      end

      context "when invalid bugsnag personal auth token is given" do
        before do
          allow(project_list).to(receive(:get).and_raise(Bugsnag::Api::Unauthorized))
        end

        it_behaves_like "puts as standard error", "Request denied because you do not have authorization."
        it_behaves_like "exit with status 1"
      end

      context "when the resource not found in Bugsnag" do
        before do
          allow(project_list).to(receive(:get).and_raise(Bugsnag::Api::NotFound))
        end

        it_behaves_like "puts as standard error", "Resource not found in Bugsnag."
        it_behaves_like "exit with status 1"
      end
    end

    context "with 'generate_csv_map' subcommand" do
      let(:subcommand) { "generate_csv_map" }
      let(:csv_map) { instance_double(BugsnagErrorEventDownloader::CsvMap) }

      before do
        allow(BugsnagErrorEventDownloader::CsvMap).to(receive(:new).and_return(csv_map))
      end

      context "when normal case" do
        before do
          allow(csv_map).to(
            receive(:generate).and_return(
              [
                {
                  "header": "$.id",
                  "path": "$.id",
                },
                {
                  "header": "$.url",
                  "path": "$.url",
                },
                {
                  "header": "$.project_url",
                  "path": "$.project_url",
                },
              ]
            )
          )
        end

        it do
          subject
          expect(BugsnagErrorEventDownloader::Output).to(
            have_received(:puts).with(
              [
                {
                  "header": "$.id",
                  "path": "$.id",
                },
                {
                  "header": "$.url",
                  "path": "$.url",
                },
                {
                  "header": "$.project_url",
                  "path": "$.project_url",
                },
              ]
            )
          )
        end
      end

      context "when no auth token" do
        before do
          allow(BugsnagErrorEventDownloader::CsvMap)
            .to(receive(:new)
            .and_raise(BugsnagErrorEventDownloader::NoAuthTokenError))
        end

        it_behaves_like "puts as standard error",
          "Set the environment variable BUGSNAG_PERSONAL_AUTH_TOKEN. "\
            "Or specify Bugsnag's token by specifying -t or -token."
        it_behaves_like "exit with status 1"
      end

      context "when the `organization_id` parameter is not received" do
        before do
          allow(BugsnagErrorEventDownloader::CsvMap)
            .to(receive(:new)
            .and_raise(BugsnagErrorEventDownloader::ValidationError.new(attributes: ["error_id"])))
        end

        it_behaves_like "puts as standard error", "You need specify 'error_id'. See -h or --help."
        it_behaves_like "exit with status 1"
      end

      context "when no value is specified for an optional argument" do
        before do
          allow(BugsnagErrorEventDownloader::CsvMap)
            .to(receive(:new)
            .and_raise(OptionParser::MissingArgument.new("-t")))
        end

        it_behaves_like "puts as standard error", "missing argument: -t. See -h or --help."
        it_behaves_like "exit with status 1"
      end

      context "when invalid bugsnag personal auth token is given" do
        before do
          allow(csv_map).to(receive(:generate).and_raise(Bugsnag::Api::Unauthorized))
        end

        it_behaves_like "puts as standard error", "Request denied because you do not have authorization."
        it_behaves_like "exit with status 1"
      end

      context "when the resource not found in Bugsnag" do
        before do
          allow(csv_map).to(receive(:generate).and_raise(Bugsnag::Api::NotFound))
        end

        it_behaves_like "puts as standard error", "Resource not found in Bugsnag."
        it_behaves_like "exit with status 1"
      end
    end

    context "with no subcommand" do
      let(:subcommand) {}
      let(:error_event_list) { instance_double(BugsnagErrorEventDownloader::ErrorEventList) }

      before do
        allow(BugsnagErrorEventDownloader::ErrorEventList).to(receive(:new).and_return(error_event_list))
      end

      context "when normal case" do
        before do
          error_event_csv = <<~HERE
            id,severity,message
            11111,Critical,Critical message
            22222,Important,Important message
            33333,Moderate,Moderate message
          HERE
          allow(error_event_list).to(receive(:get).and_return(error_event_csv))
        end

        it do
          subject
          error_event_csv = <<~HERE
            id,severity,message
            11111,Critical,Critical message
            22222,Important,Important message
            33333,Moderate,Moderate message
          HERE
          expect(BugsnagErrorEventDownloader::Output).to(
            have_received(:puts).with(error_event_csv)
          )
        end
      end

      context "when no auth token" do
        before do
          allow(BugsnagErrorEventDownloader::ErrorEventList)
            .to(receive(:new)
            .and_raise(BugsnagErrorEventDownloader::NoAuthTokenError))
        end

        it_behaves_like "puts as standard error",
          "Set the environment variable BUGSNAG_PERSONAL_AUTH_TOKEN. "\
            "Or specify Bugsnag's token by specifying -t or -token."
        it_behaves_like "exit with status 1"
      end

      context "when the `organization_id` parameter is not received" do
        before do
          allow(BugsnagErrorEventDownloader::ErrorEventList)
            .to(receive(:new)
            .and_raise(BugsnagErrorEventDownloader::ValidationError.new(attributes: ["error_id"])))
        end

        it_behaves_like "puts as standard error", "You need specify 'error_id'. See -h or --help."
        it_behaves_like "exit with status 1"
      end

      context "when no value is specified for an optional argument" do
        before do
          allow(BugsnagErrorEventDownloader::ErrorEventList)
            .to(receive(:new)
            .and_raise(OptionParser::MissingArgument.new("-t")))
        end

        it_behaves_like "puts as standard error", "missing argument: -t. See -h or --help."
        it_behaves_like "exit with status 1"
      end

      context "when invalid bugsnag personal auth token is given" do
        before do
          allow(error_event_list).to(receive(:get).and_raise(Bugsnag::Api::Unauthorized))
        end

        it_behaves_like "puts as standard error", "Request denied because you do not have authorization."
        it_behaves_like "exit with status 1"
      end

      context "when the resource not found in Bugsnag" do
        before do
          allow(error_event_list).to(receive(:get).and_raise(Bugsnag::Api::NotFound))
        end

        it_behaves_like "puts as standard error", "Resource not found in Bugsnag."
        it_behaves_like "exit with status 1"
      end

      context "when the csv_map not found" do
        before do
          allow(BugsnagErrorEventDownloader::ErrorEventList)
            .to(receive(:new)
            .and_raise(BugsnagErrorEventDownloader::Converter::CsvConverter::CsvMapNotFound))
        end

        it_behaves_like "puts as standard error", "csv_map not found."
        it_behaves_like "exit with status 1"
      end

      context "when incorrect JSON in csv_map" do
        before do
          allow(BugsnagErrorEventDownloader::ErrorEventList)
            .to(receive(:new)
            .and_raise(BugsnagErrorEventDownloader::Converter::CsvConverter::JSONInCsvMapIsInvalid))
        end

        it_behaves_like "puts as standard error", "JSON in csv_map is invalid."
        it_behaves_like "exit with status 1"
      end
    end
  end
end
