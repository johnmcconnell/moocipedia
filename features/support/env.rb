require 'cucumber/rails'
require 'factory_girl_rails'

ActionController::Base.allow_rescue = false

begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your " \
    "Gemfile (in the :test group) if you wish to use it."
end

Cucumber::Rails::Database.javascript_strategy = :truncation

success = true
After do |scenario|
  if scenario.failed?
    success = false
    Cucumber.wants_to_quit = true
    save_and_open_page
  end
end

at_exit do
  e = $!.status

  if success && e < 2
    exit(0)
  end

  exit(e)
end
