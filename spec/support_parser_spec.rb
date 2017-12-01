require "rspec"
require_relative "../lib/support_parser"

RSpec.describe SupportParser do
  describe "download_json" do
    let(:api_key) { "yourpersonalapikey" }
    let(:start_date) { "2017-11-27T00:00:00Z" }
    let(:end_date) { "2017-12-01T00:00:00Z" }
    let(:team_id) { "yourteamid" }

    before(:each) do
      stub_request(
        :get,
        "https://api.pagerduty.com/incidents?since=#{start_date}&statuses%5B%5D=resolved&team_ids%5B%5D=#{team_id}&time_zone=UTC&until=#{end_date}"
      ).with(
        headers: {
          "Accept"=>["*/*", "application/vnd.pagerduty+json;version=2"],
          "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization"=>"Token token=#{api_key}",
          "Host"=>"api.pagerduty.com", "User-Agent"=>"Ruby"
        }
      ).to_return(status: 200, body: "{\"foo\":\"bar\"}", headers: {})

    end
    it "makes a request to PagerDuty API and returns JSON parsed into a hash" do
      expected_hash = { "foo" => "bar" }
      expect(SupportParser.download_json(api_key, team_id, start_date, end_date))
        .to eq(expected_hash)
    end
  end

  describe "load_json" do
    it "accepts a path and returns a hash" do
      expected = { "foo" => "bar" }
      expect(SupportParser.load_json("./spec/test.json")).to eq(expected)
    end
  end

  describe "extract_incidents" do
    it "accepts a hash and returns resolved incidents with their duration" do
      given = {
        "incidents" => [
          {
            "created_at" => "2017-11-27T16:21:37Z",
            "status" => "resolved",
            "incident_key" => "an incident thats been resolved",
            "title" => "an incident thats been resolved",
            "last_status_change_at" => "2017-11-27T16:55:48Z",
          },
          {
            "created_at" => "2017-11-27T16:21:37Z",
            "status" => "triggered",
            "incident_key" => "an incident thats still triggered",
            "title" => "an incident thats still triggered",
            "last_status_change_at" => "2017-11-27T16:55:48Z",
          },
        ]
      }

      expected = [
        {
          "incident_key" => "an incident thats been resolved",
          "title" => "an incident thats been resolved",
          "started" => "2017-11-27T16:21:37Z",
          "ended" => "2017-11-27T16:55:48Z",
          "duration_in_minutes" => 34
        }
      ]

      expect(SupportParser.extract_incidents(given)).to eq(expected)
    end
  end
end
