# frozen_string_literal: true

# Ensure custom error classes in app/errors are autoloaded
Rails.autoloaders.main.ignore(Rails.root.join("app/errors"))

# Manually require all error files
Dir[Rails.root.join("app/errors/**/*.rb")].each { |f| require f }
