Gem::Specification.new do |s|
  s.name             = 'kknife'
  s.version          = '0.1.1'
  s.date             = '2013-12-13'

  s.platform         = Gem::Platform::RUBY
  s.extra_rdoc_files = %w( LICENSE README.md )
  s.summary          = "Shortcuts for the chef knife command"
  s.description      = "k shortcut commands for knife"
  s.author           = "Matt Hoyle"
  s.email            = "matt@deployable.co"
  s.homepage         = "http://deployable.co"
  s.license          = 'Apache'

  s.add_dependency "chef", "~> 11.0"
  s.add_dependency "trollop", "~> 2.0"

  %w(rspec-core rspec-expectations rspec-mocks).each { |gem| s.add_development_dependency gem, "~> 2.13.0" }
  s.add_development_dependency 'chef-zero', "~> 1.7"
  s.add_development_dependency 'rest_client', "~> 1.6"

  s.bindir       = "bin"
  s.executables  = %w( k )

  s.require_path = 'lib'
  s.files = %w( LICENSE README.md ) + Dir.glob("{lib,spec}/**/*", File::FNM_DOTMATCH).reject {|f| File.directory?(f) }
end