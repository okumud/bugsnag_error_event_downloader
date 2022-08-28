# frozen_string_literal: true

RSpec.describe(BugsnagErrorEventDownloader::ErrorEventList) do
  let(:instance) { described_class.new }
  let(:client) { instance_double(BugsnagErrorEventDownloader::BugsnagApiClient::ErrorEventClient) }
  let(:csv_converter) { instance_double(BugsnagErrorEventDownloader::Converter::CsvConverter) }

  before do
    allow(BugsnagErrorEventDownloader::BugsnagApiClient::ErrorEventClient).to(receive(:new).and_return(client))
    allow(BugsnagErrorEventDownloader::Converter::CsvConverter).to(receive(:new).and_return(csv_converter))
  end

  describe(".initialize") do
    context "when project_id, error_id and csv_map_path are exists" do
      it { expect(instance).to(be_a(described_class)) }
    end

    context "when project_id is not exists" do
      before do
        allow(BugsnagErrorEventDownloader::BugsnagApiClient::ErrorEventClient)
          .to(receive(:new)
          .and_raise(
            BugsnagErrorEventDownloader::ValidationError.new(attributes: ["project_id"])
          ))
      end

      it do
        expect { instance }.to(raise_error(BugsnagErrorEventDownloader::ValidationError) do |error|
          expect(error.attributes).to(eq(["project_id"]))
        end)
      end
    end

    context "when csv_map_path is not exists" do
      before do
        allow(BugsnagErrorEventDownloader::Converter::CsvConverter)
          .to(receive(:new)
          .and_raise(
            BugsnagErrorEventDownloader::ValidationError.new(attributes: ["csv_map_path"])
          ))
      end

      it do
        expect { instance }.to(raise_error(BugsnagErrorEventDownloader::ValidationError) do |error|
          expect(error.attributes).to(eq(["csv_map_path"]))
        end)
      end
    end

    context "when project_id, error_id and csv_map_path is not exists" do
      before do
        allow(BugsnagErrorEventDownloader::BugsnagApiClient::ErrorEventClient)
          .to(receive(:new)
          .and_raise(
            BugsnagErrorEventDownloader::ValidationError.new(attributes: ["project_id", "error_id"])
          ))
        allow(BugsnagErrorEventDownloader::Converter::CsvConverter)
          .to(receive(:new)
          .and_raise(
            BugsnagErrorEventDownloader::ValidationError.new(attributes: ["csv_map_path"])
          ))
      end

      it do
        expect { instance }.to(raise_error(BugsnagErrorEventDownloader::ValidationError) do |error|
          expect(error.attributes).to(contain_exactly("project_id", "error_id", "csv_map_path"))
        end)
      end
    end
  end

  describe("#get") do
    subject(:get) { instance.get }

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
    let(:error_event_csv) do
      <<~HERE
        id,url,project_url,received_at
        33333,https://api.bugsnag.com/projects/11111/events/33333,https://api.bugsnag.com/projects/11111,2022-01-01 00:00:00.000 UTC
      HERE
    end

    before do
      allow(client).to(receive(:fetch_all).and_return([error_event]))
      allow(csv_converter).to(receive(:convert).and_return(error_event_csv))
    end

    it do
      expect(subject).to(eq(error_event_csv))
    end
  end
end
