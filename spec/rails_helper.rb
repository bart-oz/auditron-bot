# frozen_string_literal: true

require "spec_helper"
require "rspec/rails"
require "simplecov"
require "simplecov_json_formatter"

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]

SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/vendor/"
  add_filter "/tmp/"
  add_filter "/public/"
  add_filter "/log/"
  add_filter "/storage/"

  minimum_coverage 95
  minimum_coverage_by_file 80

  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Jobs", "app/jobs"
  add_group "Services", "app/services"
  add_group "Interactors", "app/interactors"
  add_group "Policies", "app/policies"
  add_group "Serializers", "app/serializers"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

abort("The Rails environment is running in production mode!") if Rails.env.production?

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
end
