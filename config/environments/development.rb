require "active_support/core_ext/integer/time"
require 'colorize'

Rails.application.configure do
  config.hosts << ENV['TUNNELLED_HOST'] if ENV['TUNNELLED_HOST'].present? # allows use of ngrok and similar services
  config.active_storage.service = ENV['ACTIVE_STORAGE_SERVICE'].to_sym
  # Settings specified here will take precedence over those in config/application.rb.

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
  config.solid_queue.silence_polling = true
  config.solid_queue.preserve_finished_jobs = true
  config.solid_queue.clear_finished_jobs_after = 2.days

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "debug")

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = false
  config.exceptions_app = self.routes

  # Enable server timing.
  config.server_timing = true

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  # Run rails dev:cache to toggle Action Controller caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  # Change to :null_store to avoid any caching.
  # config.cache_store = :memory_store
  config.cache_store = :solid_cache_store

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Make template changes take effect immediately.
  config.action_mailer.perform_caching = false

  # Set localhost to be used by links generated in mailer templates.
  # ACTUALLY SET IN environment.rb
  # config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Append comments with runtime information tags to SQL queries in logs.
  config.active_record.query_log_tags_enabled = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = :strict

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Apply autocorrection by RuboCop to files generated by `bin/rails generate`.
  # config.generators.apply_rubocop_autocorrect_after_generate!
end

class CustomLoggerFormatter < Logger::Formatter
  def call(severity, time, progname, msg)
    if ["ERROR", "FATAL"].include? severity
      "#{severity}: #{msg}\n".light_red
    elsif severity == "DEBUG" then
      "#{severity}: #{msg}\n".light_yellow
    elsif severity == "WARN" then
      "#{severity}: #{msg}\n".light_magenta
    else
      "#{severity}: #{msg}\n".light_cyan
    end
  end
end

new_rails_logger = ActiveSupport::Logger.new(STDOUT)
new_rails_logger.formatter = CustomLoggerFormatter.new
Rails.logger = ActiveSupport::TaggedLogging.new(new_rails_logger)

new_active_record_logger = ActiveSupport::Logger.new(STDOUT)
new_active_record_logger.formatter = CustomLoggerFormatter.new
ActiveRecord::Base.logger = ActiveSupport::TaggedLogging.new(new_active_record_logger)
ActiveRecord::Base.logger.level = :warn
