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
