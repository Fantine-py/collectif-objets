# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.0"

gem "bootsnap", require: false
gem "importmap-rails"
gem "pg", "~> 1.3"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.1"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails"
  gem "rspec-rails", "~> 5.1"
  gem "rubocop", require: false
end

group :development do
  gem "htmlbeautifier"
  gem "pry"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

gem "pagy", "~> 5.10"

gem "devise", "~> 4.8"
