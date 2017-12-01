# PagerDuty Stats

The purpose of this repo is to help gather metrics around how much time is spent responding to pages in PagerDuty

# Getting started

- copy `.env.example` and use real values
- `bundle`

# Debugging

`bin/pry`

# Testing

`bin/rspec spec`

# Getting Stats

- set env vars for start and end dates for the range of time you're intested in
- `ruby get_totals.rb`
