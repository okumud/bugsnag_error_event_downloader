# frozen_string_literal: true

RSpec.describe(BugsnagErrorEventDownloader::Converter::CsvConverter) do
  let(:instance) { described_class.new }
  let(:option) { instance_double(BugsnagErrorEventDownloader::Option) }

  before do
    allow(BugsnagErrorEventDownloader::Option).to(receive(:new).and_return(option))
  end

  describe(".initialize") do
    context "when csv_map_path are exists" do
      before do
        allow(option).to(receive(:get).with(:csv_map_path).and_return("spec/fixtures/sample_csv_map.json"))
      end

      it { expect(instance).to(be_a(described_class)) }
    end

    context "when csv_map_path is not exists" do
      before do
        allow(option).to(receive(:get).with(:csv_map_path).and_return(nil))
      end

      it do
        expect { instance }.to(raise_error(BugsnagErrorEventDownloader::ValidationError) do |error|
          expect(error.attributes).to(eq(["csv_map_path"]))
        end)
      end
    end

    context "when the csv_map_file is not exists" do
      before do
        allow(option).to(receive(:get).with(:csv_map_path).and_return("spec/fixtures/not_exists.json"))
      end

      it { expect { instance }.to(raise_error(described_class::CsvMapNotFound)) }
    end

    context "when the csv_map_file is invalid" do
      before do
        allow(option).to(receive(:get).with(:csv_map_path).and_return("spec/fixtures/invalid_csv_map.json"))
      end

      it { expect { instance }.to(raise_error(described_class::JSONInCsvMapIsInvalid)) }
    end
  end

  describe("#convert") do
    subject(:convert) { instance.convert(events) }

    before do
      allow(option).to(receive(:get).with(:csv_map_path).and_return("spec/fixtures/sample_csv_map.json"))
    end

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
