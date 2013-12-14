# A sample Gemfile
source "https://rubygems.org"
gemspec :name => "kknife"

gem "trollop", "~> 2.0"
gem "chef", "~> 11.0"

group(:development, :test) do
  gem "chef-zero", "~> 1.7"
  gem 'rest_client', "~> 1.6"
  gem 'rspec-core', "~> 2.13"
  gem 'rspec-expectations', "~> 2.13"
  gem 'rspec-mocks', "~> 2.13"
end

# If you want to load debugging tools into the bundle exec sandbox,
# add these additional dependencies into chef/Gemfile.local
eval(IO.read(__FILE__ + '.local'), binding) if File.exists?(__FILE__ + '.local')