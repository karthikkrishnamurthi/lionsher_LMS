require 'aws/ses'
Lionsher::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
  AWS_SES = AWS::SES::Base.new :access_key_id => "AKIAJDSZSCTI5D6KEK6Q", :secret_access_key => "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"

#These below details must be on local(development) for a TEST Transaction
#SITE_URL  = "kern.loc:3000"
#EBS_KEY   = 'ebskey'
#EBS_ACCOUNT_ID = '5880'
#EBS_TRANSACTION_MODE = 'TEST'
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
