# frozen_string_literal: true

# Bullet configuration for detecting N+1 queries and unused eager loading
if defined?(Bullet)
  Bullet.enable = true
  Bullet.alert = false
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
  Bullet.add_footer = true

  # Raise errors in test environment to catch N+1 queries early
  Bullet.raise = Rails.env.test?
end
