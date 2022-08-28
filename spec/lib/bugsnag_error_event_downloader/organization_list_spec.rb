# frozen_string_literal: true

RSpec.describe(BugsnagErrorEventDownloader::OrganizationList) do
  let(:instance) { described_class.new }

  describe "#get" do
    subject { instance.get }

    before do
      client = instance_double(
        BugsnagErrorEventDownloader::BugsnagApiClient::Client,
        organizations: [organization1, organization2]
      )
      allow(BugsnagErrorEventDownloader::BugsnagApiClient::Client).to(receive(:new).and_return(client))
    end

    let(:organization1) do
      agent = Sawyer::Agent.new("https://api.bugsnag.com")
      data = {
        id: "11111",
        name: "Some Organization1",
        slug: "some-organization1",
        creator: nil,
        collaborators_url: "https://api.bugsnag.com/organizations/11111/collaborators",
        projects_url: "https://api.bugsnag.com/organizations/11111/projects",
        created_at: Time.now,
        updated_at: Time.now,
        auto_upgrade: false,
        upgrade_url: "https://api.bugsnag.com/settings/example/plans-billing?plansBilling%5Bstep%5D=collaborators-and-events",
        can_start_pro_trial: true,
        pro_trial_ends_at: Time.now,
        pro_trial_feature: true,
        billing_emails: ["bugsnag_error_event_downloader@example.com"],
      }
      Sawyer::Resource.new(agent, data)
    end

    let(:organization2) do
      agent = Sawyer::Agent.new("https://api.bugsnag.com")
      data = {
        id: "22222",
        name: "Some Organization2",
        slug: "some-organization2",
        creator: nil,
        collaborators_url: "https://api.bugsnag.com/organizations/22222/collaborators",
        projects_url: "https://api.bugsnag.com/organizations/22222/projects",
        created_at: Time.now,
        updated_at: Time.now,
        auto_upgrade: false,
        upgrade_url: "https://api.bugsnag.com/settings/example/plans-billing?plansBilling%5Bstep%5D=collaborators-and-events",
        can_start_pro_trial: true,
        pro_trial_ends_at: Time.now,
        pro_trial_feature: true,
        billing_emails: ["bugsnag_error_event_downloader@example.com"],
      }
      Sawyer::Resource.new(agent, data)
    end

    it "returns an array of organization.id and organization.slug pairs" do
      expect(subject).to(
        eq(
          [
            "11111,some-organization1",
            "22222,some-organization2",
          ]
        )
      )
    end
  end
end
