# frozen_string_literal: true

RSpec.describe(BugsnagErrorEventDownloader::ProjectList) do
  let(:instance) { described_class.new }

  describe "#get" do
    subject { instance.get }

    before do
      option = instance_double(BugsnagErrorEventDownloader::Option)
      allow(BugsnagErrorEventDownloader::Option).to(receive(:new).and_return(option))
      allow(option).to(receive(:get).with(:organization_id).and_return(organization_id))

      allow(BugsnagErrorEventDownloader::BugsnagApiClient::Client).to(receive(:new).and_return(client))
      allow(client).to(receive(:projects).and_return([project1, project2]))
    end

    let(:client) { instance_double(BugsnagErrorEventDownloader::BugsnagApiClient::Client) }
    let(:organization_id) { "99999" }

    let(:project1) do
      agent = Sawyer::Agent.new("https://api.bugsnag.com")
      data = {
        id: "11111",
        organization_id: organization_id,
        slug: "example-project1",
        name: "Example Project1",
        api_key: "api_key",
        type: "rails",
        is_full_view: true,
        release_stages: ["production", "staging"],
        language: "ruby",
        created_at: Time.now,
        updated_at: Time.now,
        errors_url: "https://api.bugsnag.com/projects/11111/errors",
        events_url: "https://api.bugsnag.com/projects/11111/events",
        url: "https://api.bugsnag.com/projects/11111",
        html_url: "https://app.bugsnag.com/example/example-project",
        open_error_count: 0,
        for_review_error_count: 0,
        collaborators_count: 10,
        teams_count: 1,
        global_grouping: [],
        location_grouping: [],
        discarded_app_versions: [],
        discarded_errors: [],
        custom_event_fields_used: 0,
        resolve_on_deploy: false,
      }
      Sawyer::Resource.new(agent, data)
    end

    let(:project2) do
      agent = Sawyer::Agent.new("https://api.bugsnag.com")
      data = {
        id: "22222",
        organization_id: organization_id,
        slug: "example-project2",
        name: "Example Project2",
        api_key: "api_key",
        type: "rails",
        is_full_view: true,
        release_stages: ["production", "staging"],
        language: "ruby",
        created_at: Time.now,
        updated_at: Time.now,
        errors_url: "https://api.bugsnag.com/projects/22222/errors",
        events_url: "https://api.bugsnag.com/projects/22222/events",
        url: "https://api.bugsnag.com/projects/22222",
        html_url: "https://app.bugsnag.com/example/example-project",
        open_error_count: 0,
        for_review_error_count: 0,
        collaborators_count: 10,
        teams_count: 1,
        global_grouping: [],
        location_grouping: [],
        discarded_app_versions: [],
        discarded_errors: [],
        custom_event_fields_used: 0,
        resolve_on_deploy: false,
      }
      Sawyer::Resource.new(agent, data)
    end

    it "returns an array of project.id and project.slug pairs" do
      expect(subject).to(
        eq(
          [
            "11111,example-project1",
            "22222,example-project2",
          ]
        )
      )
    end

    it "BugsnagErrorEventDownloader::Client#projects receives the organization_id" do
      subject
      expect(client).to(have_received(:projects).with(organization_id))
    end
  end
end
