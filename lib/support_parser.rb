require "json"
require "pry"
require "time"
require "dotenv/load"
require "net/http"
require "openssl"
require "csv"

class SupportParser
  def self.download_json(api_key, team_id, start_date, end_date)
    uri = URI("https://api.pagerduty.com/incidents?since=#{start_date}&until=#{end_date}&statuses%5B%5D=resolved&team_ids%5B%5D=#{team_id}&time_zone=UTC")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    req =  Net::HTTP::Get.new(uri)
    req.add_field "Authorization", "Token token=#{api_key}"
    req.add_field "Accept", "application/vnd.pagerduty+json;version=2"

    # Fetch Request
    res = http.request(req)
    JSON.parse(res.body)

  rescue StandardError => e
    puts "HTTP Request failed (#{e.message})"
  end

  def self.load_json(path)
    file = File.read(path)
    JSON.parse(file)
  end

  def self.extract_incidents(raw_incidents)
    filtered_incidents = raw_incidents["incidents"].select {|i| i["status"] == "resolved" }
    filtered_incidents.map do |incident|
      start_time = Time.parse(incident["last_status_change_at"])
      end_time = Time.parse(incident["created_at"])
      duration_in_minutes = (start_time - end_time) / 60
      {
        "incident_key" => incident["incident_key"],
        "title" => incident["title"],
        "started" => incident["created_at"],
        "ended" => incident["last_status_change_at"],
        "duration_in_minutes" => duration_in_minutes.floor,
      }
    end
  end

  def self.to_csv(extracted)
    CSV.open("./tmp/file.csv", "wb") do |csv|
      extracted.each do |incident|
        csv << [
          "Any",
          incident["title"],
          "",
          incident["started"],
          incident["ended"],
          "Yes",
          incident["duration_in_minutes"],
          "?"
        ]
      end
    end
  end
end
