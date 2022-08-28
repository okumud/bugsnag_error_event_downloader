# frozen_string_literal: true

RSpec.describe(BugsnagErrorEventDownloader::BugsnagApiClient::Client) do
  before do
    ENV["BUGSNAG_PERSONAL_AUTH_TOKEN"] = nil
  end

  describe ".initialize" do
    subject { described_class.new }

    context "when BUGSNAG_PERSONAL_AUTH_TOKEN exists" do
      before do
        ENV["BUGSNAG_PERSONAL_AUTH_TOKEN"] = "bugsnag_personal_auth_token"
      end

      it { expect(subject).to(be_a(described_class)) }
    end

    context "when the token option exists" do
      before do
        option = instance_double(BugsnagErrorEventDownloader::Option)
        allow(BugsnagErrorEventDownloader::Option).to(receive(:new).and_return(option))
        allow(option).to(receive(:has?).with(:token).and_return(true))
        allow(option).to(receive(:get).with(:token).and_return("bugsnag_personal_auth_token"))
      end

      it { expect(subject).to(be_a(described_class)) }
    end

    context "when the token does not exist" do
      it { expect { subject }.to(raise_error(BugsnagErrorEventDownloader::NoAuthTokenError)) }
    end
  end
end
