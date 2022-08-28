# frozen_string_literal: true

RSpec.describe(BugsnagErrorEventDownloader::CsvMap) do
  let(:instance) { described_class.new }
  let(:client) { instance_double(BugsnagErrorEventDownloader::BugsnagApiClient::ErrorEventClient) }
  let(:option) { instance_double(BugsnagErrorEventDownloader::Option) }

  before do
    allow(BugsnagErrorEventDownloader::BugsnagApiClient::ErrorEventClient).to(receive(:new).and_return(client))
    allow(BugsnagErrorEventDownloader::Option).to(receive(:new).and_return(option))
    allow(option).to(receive(:get).with(:include_stacktrace))
    allow(option).to(receive(:get).with(:include_breadcrumbs))
  end

  describe(".initialize") do
    context "when project_id and error_id are exists" do
      before do
        allow(option).to(receive(:get).with(:project_id).and_return("project_id"))
        allow(option).to(receive(:get).with(:error_id).and_return("error_id"))
      end

      it { expect(instance).to(be_a(described_class)) }
    end

    context "when project_id is not exists" do
      before do
        allow(option).to(receive(:get).with(:project_id).and_return(nil))
        allow(option).to(receive(:get).with(:error_id).and_return("error_id"))
      end

      it do
        expect { instance }.to(raise_error(BugsnagErrorEventDownloader::ValidationError) do |error|
          expect(error.attributes).to(eq(["project_id"]))
        end)
      end
    end

    context "when error_id is not exists" do
      before do
        allow(option).to(receive(:get).with(:project_id).and_return("project_id"))
        allow(option).to(receive(:get).with(:error_id).and_return(nil))
      end

      it do
        expect { instance }.to(raise_error(BugsnagErrorEventDownloader::ValidationError) do |error|
          expect(error.attributes).to(eq(["error_id"]))
        end)
      end
    end
  end

  describe("#generate") do
    subject(:generate) { instance.generate }

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
      allow(option).to(receive(:get).with(:project_id).and_return("project_id"))
      allow(option).to(receive(:get).with(:error_id).and_return("error_id"))
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
