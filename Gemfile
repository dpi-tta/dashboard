source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "awesome_print"
gem "blazer"
gem "bootsnap", require: false
gem "bootstrap5-kaminari-views", "~> 0.0.1"
gem "carrierwave"
gem "chartkick"
gem "cloudinary"
gem "devise"
gem "discordrb"
gem "gemoji"
gem "groupdate"
gem "faker"
gem "http"
gem "json"
gem "importmap-rails"
gem "jbuilder"
gem "kaminari", "~> 1.2"
gem "mission_control-jobs"
gem "paper_trail" # TODO: upgrade for rails 8
gem "pg", "~> 1.1"
gem "puma", "~> 6.0"
gem "pundit"
gem "ransack"
gem "rails", "~> 8.0"
gem "rails_admin", "~> 3.1"
gem "rolify", "~> 6.0"
gem "rollbar", "~> 3.4"
gem "sassc-rails", "~> 2.1"
gem "sendgrid-ruby", "~> 6.6"
gem "simple_active_link_to"
gem "smarter_csv"
gem "solid_queue"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :production do
  gem "rack-timeout"
end

group :development, :test do
  gem "better_errors"
  gem "binding_of_caller"
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "pry-rails"
  gem "rack-mini-profiler"
  gem "rspec-rails"
  gem "standard", require: false
  gem "web-console"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "annotate"
  gem "bullet", "~> 8.0"
  gem "dockerfile-rails", ">= 1.7"
  gem "letter_opener"
  gem "rails_db", ">= 2.3.1"
  gem "rails-erd"
  gem "rails_live_reload"
end
