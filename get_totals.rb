require_relative "./lib/support_parser"

s = SupportParser

results =
  s.extract_incidents(s.download_json(ENV["API_KEY"], ENV["TEAM_ID"], ENV["START_DATE"], ENV["END_DATE"]))

puts results
