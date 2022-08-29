# frozen_string_literal: true

RSpec.describe(BugsnagErrorEventDownloader::CLI) do
  subject { described_class.start(argv) }

  before do
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

  describe "#organizations" do
    let(:argv) { ["organizations"] }
    let(:organizations) { instance_double(BugsnagErrorEventDownloader::Commands::Organizations) }

    before do
      allow(BugsnagErrorEventDownloader::Commands::Organizations).to(receive(:new).and_return(organizations))
    end

    context "when normal case" do
      before do
        allow(organizations).to(receive(:get).and_return([
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
        allow(BugsnagErrorEventDownloader::Commands::Organizations)
          .to(receive(:new)
          .and_raise(BugsnagErrorEventDownloader::NoAuthTokenError))
      end

      it_behaves_like "puts as standard error",
        "Set the environment variable BUGSNAG_PERSONAL_AUTH_TOKEN. "\
          "Or specify Bugsnag's token by specifying -t or -token."
      it_behaves_like "exit with status 1"
    end

    context "when invalid bugsnag personal auth token is given" do
      before do
        allow(organizations).to(receive(:get).and_raise(Bugsnag::Api::Unauthorized))
      end

      it_behaves_like "puts as standard error", "Request denied because you do not have authorization."
      it_behaves_like "exit with status 1"
    end
  end

  describe "#projects" do
    let(:argv) { ["projects", "--organization_id", "organization_id"] }
    let(:projects) { instance_double(BugsnagErrorEventDownloader::Commands::Projects) }

    before do
      allow(BugsnagErrorEventDownloader::Commands::Projects).to(receive(:new).and_return(projects))
    end

    context "when normal case" do
      before do
        allow(projects).to(receive(:get).and_return([
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
        allow(BugsnagErrorEventDownloader::Commands::Projects)
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
        allow(BugsnagErrorEventDownloader::Commands::Projects)
          .to(receive(:new)
          .and_raise(BugsnagErrorEventDownloader::ValidationError.new(attributes: ["organization_id"])))
      end

      it_behaves_like "puts as standard error", "You need specify 'organization_id'. See -h or --help."
      it_behaves_like "exit with status 1"
    end

    context "when invalid bugsnag personal auth token is given" do
      before do
        allow(projects).to(receive(:get).and_raise(Bugsnag::Api::Unauthorized))
      end

      it_behaves_like "puts as standard error", "Request denied because you do not have authorization."
      it_behaves_like "exit with status 1"
    end

    context "when the resource not found in Bugsnag" do
      before do
        allow(projects).to(receive(:get).and_raise(Bugsnag::Api::NotFound))
      end

      it_behaves_like "puts as standard error", "Resource not found in Bugsnag."
      it_behaves_like "exit with status 1"
    end
  end

  describe "#generate_csv_map" do
    let(:argv) { ["generate_csv_map", "--project_id", "project_id", "--error_id", "error_id"] }
    let(:csv_map) { instance_double(BugsnagErrorEventDownloader::Commands::GenerateCsvMap) }

    before do
      allow(BugsnagErrorEventDownloader::Commands::GenerateCsvMap).to(receive(:new).and_return(csv_map))
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
        allow(BugsnagErrorEventDownloader::Commands::GenerateCsvMap)
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
        allow(BugsnagErrorEventDownloader::Commands::GenerateCsvMap)
          .to(receive(:new)
          .and_raise(BugsnagErrorEventDownloader::ValidationError.new(attributes: ["error_id"])))
      end

      it_behaves_like "puts as standard error", "You need specify 'error_id'. See -h or --help."
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

  describe "#error_events" do
    let(:subcommand) {}
    let(:argv) do
      [
        "error_events",
        "--project_id",
        "project_id",
        "--error_id",
        "error_id",
        "--csv_map_path",
        "spec/fixtures/invalid_csv_map.json",
      ]
    end
    let(:error_event_list) { instance_double(BugsnagErrorEventDownloader::Commands::ErrorEvents) }

    before do
      allow(BugsnagErrorEventDownloader::Commands::ErrorEvents).to(receive(:new).and_return(error_event_list))
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
        allow(BugsnagErrorEventDownloader::Commands::ErrorEvents)
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
        allow(BugsnagErrorEventDownloader::Commands::ErrorEvents)
          .to(receive(:new)
          .and_raise(BugsnagErrorEventDownloader::ValidationError.new(attributes: ["error_id"])))
      end

      it_behaves_like "puts as standard error", "You need specify 'error_id'. See -h or --help."
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
        allow(BugsnagErrorEventDownloader::Commands::ErrorEvents)
          .to(receive(:new)
          .and_raise(BugsnagErrorEventDownloader::Converter::CsvConverter::CsvMapNotFound))
      end

      it_behaves_like "puts as standard error", "csv_map not found."
      it_behaves_like "exit with status 1"
    end

    context "when incorrect JSON in csv_map" do
      before do
        allow(BugsnagErrorEventDownloader::Commands::ErrorEvents)
          .to(receive(:new)
          .and_raise(BugsnagErrorEventDownloader::Converter::CsvConverter::JSONInCsvMapIsInvalid))
      end

      it_behaves_like "puts as standard error", "JSON in csv_map is invalid."
      it_behaves_like "exit with status 1"
    end
  end
end
