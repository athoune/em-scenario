require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
end

desc "Builds the gem"
task :gem do
  Gem::Builder.new(eval(File.read('em-ucengine.gemspec'))).build
end

task :default => :test
