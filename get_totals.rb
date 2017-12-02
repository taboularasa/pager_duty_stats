require_relative "./lib/support_parser"

args = [ENV["API_KEY"], ENV["TEAM_ID"], ENV["START_DATE"], ENV["END_DATE"]]
s = SupportParser
s.to_csv(s.extract_incidents(s.download_json(*args)))

puts "done! find results at `./tmp/file.csv`"
