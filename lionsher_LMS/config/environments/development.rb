require 'aws/ses'
Lionsher::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.gem 'paperclip'
  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true
  
  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = false

  # Raise exception on mass assignment protection for Active Record models
  #  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = nil

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true

  ActionMailer::Base.smtp_settings              = {
    :address              => "smtp.sendgrid.net",
    :port                 => "587",
    :domain               => "localhost:3000",
    :enable_starttls_auto => true,
    :authentication       => "plain",
    :user_name            => "ripul",
    :password             => "Kerncomm123"
    #      :user_name            => "lionsher",
    #      :password             => "Kerncomm123"
  }

  
  AWS_SES = AWS::SES::Base.new :access_key_id => "AKIAJDSZSCTI5D6KEK6Q", :secret_access_key => "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"

  #These below details must be on local(development) for a TEST Transaction
#  SITE_URL  = "aarthi.loc:3000"
#  EBS_KEY   = 'ebskey'
#  EBS_ACCOUNT_ID = '5880'
#  EBS_TRANSACTION_MODE = 'TEST'
  #These are the details which we need to enter in the ebs form in TEST mode
  #name on the card: name can be anything
  # card number: 4111-1111-1111-1111
  #card expiry date:  july 2016
  #cvv:  123

  #These below details must be on production for a LIVE Transaction
  SITE_URL  = "kernlearning.com"
  EBS_KEY   = '6f064d02dd905a7b9975db08f3777e9f'
  EBS_ACCOUNT_ID = '7429'
  EBS_TRANSACTION_MODE = 'LIVE'

  #send grid web api
  SEND_GRID_URL = 'http://sendgrid.com/'
  SEND_GRID_USERNAME = 'ripul'
  SEND_GRID_PASSWORD = 'Kerncomm123'

  #instantiate object for bounce class only once
  BOUNCES = SendgridToolkit::Bounces.new(SEND_GRID_USERNAME, SEND_GRID_PASSWORD)

  #AWS_SES BATCH SIZE
  AWS_SES_BATCH_SIZE = 100

  #AWS_SES MAX SEND RATE per second
  AWS_SES_QUOTA = AWS_SES.quota
end
