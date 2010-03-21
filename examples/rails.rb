
# put in config/initializers/bunyan.rb
Bunyan::Logger.configure do |config|
  # required options
  config.database   "bunyan_logger"
  config.collection "#{RAILS_ENV}_log"

  # optional
  config.size       75.megabytes
end

