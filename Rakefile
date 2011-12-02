require 'rake/gempackagetask'
require 'rubygems'

# Gem stuff
spec = Gem::Specification.new do |s|
  s.name = 'eventer'
  s.version = '1.0.0'
  s.author = 'Datadog, Inc.'
  s.email = 'packages@datadoghq.com'
  s.homepage = 'http://datadoghq.com/'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A DSL for generating Datadog events'
  s.description = s.summary
  s.files = FileList['lib/**/*'].to_a
  s.require_path = 'lib'
  s.license = 'BSD'

  s.has_rdoc = false
  s.add_dependency 'dogapi', '>=1.2.6'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
