Gem::Specification.new do |s|
  s.name        = "merge-mongoid"
  s.version     = "0.1"
  s.author      = "Fabien Allanic"
  s.homepage    = "http://github.com/fallanic/merge-mongoid"
  s.summary     = "Easily merge two Mongoid documents."
  s.description = "Easily merge two Mongoid documents. When merging document B into document A, arrays and nested objects will be merged. For the other data types we keep Document A values."

  s.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_development_dependency 'rspec', '~> 2.14.1' 
  s.add_development_dependency 'rails', '>= 3.2.0'
  s.add_development_dependency 'factory_girl_rails', '~> 3.6.0'
  s.add_runtime_dependency 'mongoid', "~> 3.1.6"

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end