# A sample Gemfile
source "https://rubygems.org"
gemspec :name => "kknife"

gem "trollop", "~> 2.0"
gem "chef", "~> 12.0"

group(:development, :test) do
  gem 'rest-client', "~> 1.8"
  gem 'rspec-core', "~> 3.2"
  gem 'rspec-expectations', "~> 3.2"
  gem 'rspec-mocks', "~> 3.2"
end

# If you want to load debugging tools into the bundle exec sandbox,
# add these additional dependencies into chef/Gemfile.local
eval(IO.read(__FILE__ + '.local'), binding) if File.exists?(__FILE__ + '.local')
