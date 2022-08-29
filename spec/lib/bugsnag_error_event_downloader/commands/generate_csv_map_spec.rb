# frozen_string_literal: true

RSpec.describe(BugsnagErrorEventDownloader::Commands::GenerateCsvMap) do
  let(:instance) do
    described_class.new(
      project_id: project_id,
      error_id: error_id,
      include_stacktrace: include_stacktrace,
      include_breadcrumbs: include_breadcrumbs
    )
  end
  let(:client) { instance_double(BugsnagErrorEventDownloader::BugsnagApiClient::ErrorEventClient) }
  let(:include_stacktrace) { false }
  let(:include_breadcrumbs) { false }

  before do
    allow(BugsnagErrorEventDownloader::BugsnagApiClient::ErrorEventClient).to(receive(:new).and_return(client))
  end

  describe(".initialize") do
    context "when project_id and error_id are exists" do
      let(:project_id) { "project_id" }
      let(:error_id) { "error_id" }

      it { expect(instance).to(be_a(described_class)) }

      it do
        instance
        expect(BugsnagErrorEventDownloader::BugsnagApiClient::ErrorEventClient)
          .to(have_received(:new)
          .with(
            project_id: project_id,
            error_id: error_id
          ))
      end
    end
  end

  describe("#generate") do
    subject(:generate) { instance.generate }

    let(:project_id) { "project_id" }
    let(:error_id) { "error_id" }

    let(:error_event) do
      agent = Sawyer::Agent.new("https://api.bugsnag.com")
      data = {
        id: "33333",
        url: "https://api.bugsnag.com/projects/11111/events/33333",
        project_url: "https://api.bugsnag.com/projects/11111",
        is_full_report: true,
        error_id: "22222",
        received_at: "2022-01-01 00:00:00.000 UTC",
        exception: [
          {
            error_class: "NotFoundError",
            message: "Response code = 404",
          },
        ],
      }
      Sawyer::Resource.new(agent, data)
    end

    before do
      allow(client).to(receive(:fetch_first).and_return([error_event]))
    end

    it do
      expect(JSON.parse(subject)).to(eq([
        { "header" => "$.id", "path" => "$.id" },
        { "header" => "$.url", "path" => "$.url" },
        { "header" => "$.project_url", "path" => "$.project_url" },
        { "header" => "$.is_full_report", "path" => "$.is_full_report" },
        { "header" => "$.error_id", "path" => "$.error_id" },
        { "header" => "$.received_at", "path" => "$.received_at" },
        { "header" => "$.exception", "path" => "$.exception" },
        { "header" => "$.exception[0].error_class", "path" => "$.exception[0].error_class" },
        { "header" => "$.exception[0].message", "path" => "$.exception[0].message" },
        { "header" => "$.exception[0]", "path" => "$.exception[0]" },
      ]))
    end
  end
end
