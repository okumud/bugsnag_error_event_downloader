# frozen_string_literal: true

RSpec.describe(BugsnagErrorEventDownloader::Converter::CsvConverter) do
  let(:instance) { described_class.new(csv_map_path: csv_map_path) }
  let(:option) { instance_double(BugsnagErrorEventDownloader::Option) }

  before do
    allow(BugsnagErrorEventDownloader::Option).to(receive(:new).and_return(option))
  end

  describe(".initialize") do
    context "when a valid JSON file exists in the csv_map_path" do
      let(:csv_map_path) { "spec/fixtures/sample_csv_map.json" }

      it { expect(instance).to(be_a(described_class)) }
    end

    context "when csv_map_path parameter is not given" do
      let(:csv_map_path) { nil }

      it do
        expect { instance }.to(raise_error(BugsnagErrorEventDownloader::ValidationError) do |error|
          expect(error.attributes).to(eq(["csv_map_path"]))
        end)
      end
    end

    context "when file does not exist in csv_map_path" do
      let(:csv_map_path) { "spec/fixtures/not_exists.json" }

      it { expect { instance }.to(raise_error(described_class::CsvMapNotFound)) }
    end

    context "when a invalid JSON file exists in the csv_map_path" do
      let(:csv_map_path) { "spec/fixtures/invalid_csv_map.json" }

      it { expect { instance }.to(raise_error(described_class::JSONInCsvMapIsInvalid)) }
    end
  end

  describe("#convert") do
    subject(:convert) { instance.convert(events) }

    let(:csv_map_path) { "spec/fixtures/sample_csv_map.json" }

    let(:events) do
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
      [Sawyer::Resource.new(agent, data)]
    end

    it do
      error_csv = <<~HERE
        id,url,project_url,received_at
        33333,https://api.bugsnag.com/projects/11111/events/33333,https://api.bugsnag.com/projects/11111,2022-01-01 00:00:00.000 UTC
      HERE
      expect(convert).to(eq(error_csv))
    end
  end
end
