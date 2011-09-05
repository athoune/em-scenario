require 'rubygems'
require 'rake/testtask'
require 'rubygems/package_task'

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
end

Gem::PackageTask.new(eval(File.read('em-scenario.gemspec'))) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

task :default => :test
