begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "bunyan"
    gemspec.summary = "A MongoDB-based logging solution."
    gemspec.description = "Bunyan is a thin ruby wrapper around a MongoDB capped collection, created with high-performance, flexible logging in mind."
    gemspec.email = "ajsharp@gmail.com"
    gemspec.homepage = "http://github.com/ajsharp/bunyan"
    gemspec.authors = ["Alex Sharp"]
    gemspec.add_dependency 'mongo',     '~> 1.0.9'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

begin
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new

  Spec::Rake::SpecTask.new(:specs_with_coverage) do |t|
    t.spec_files = FileList['spec/*_spec.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec', '--exclude', 'gems']
  end
rescue LoadError
end

task :default => :spec
