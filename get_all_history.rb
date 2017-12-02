require_relative "./lib/support_parser"

args = [ENV["API_KEY"], ENV["TEAM_ID"]]
s = SupportParser
s.to_csv(s.extract_incidents(s.download_all_json(*args)))

puts "done! find results at `./tmp/file.csv`"
