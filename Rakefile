begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "bunyan"
    gemspec.summary = "A MongoDB-based logging solution."
    gemspec.description = "Bunyan is a thin ruby wrapper around a MongoDB capped collection, created with high-performance, flexible logging in mind."
    gemspec.email = "ajsharp@gmail.com"
    gemspec.homepage = "http://github.com/ajsharp/bunyan"
    gemspec.authors = ["Alex Sharp"]
    gemspec.add_dependency 'mongo',     '~> 1.0.8'
    gemspec.add_dependency 'bson_ext',  '~> 1.0.7'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

task :default do
  system("spec spec")
end
