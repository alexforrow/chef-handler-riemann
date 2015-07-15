Gem::Specification.new do |s|
  s.name = 'chef-handler-riemann'
  s.version = '0.1.3'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Chef start, exception & reporting handler for Riemann.'
  s.description = "Provides insight into Chef status from within Riemann"
  s.author = 'Alex Forrow'
  s.email = 'alex.forrow@datasift.com'
  s.homepage = 'http://github.com/alexforrow/chef-handler-riemann'
  s.require_path = 'lib'
  s.files = %w(README.md) + Dir.glob('lib/**/*')
  s.add_runtime_dependency 'riemann-client', '~> 0'
end
