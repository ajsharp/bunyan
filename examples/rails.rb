
# put in config/initializers/bunyan.rb
Bunyan::Logger.configure do
  # required options
  database   "bunyan_logger"
  collection "#{RAILS_ENV}_log"

  # optional
  size       75.megabytes
end

