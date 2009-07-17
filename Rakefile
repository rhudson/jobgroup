# gemspec for the techtrovert gem
#
# To generate:
#   rake pkg/techtrovert-0.9.0.gem
#
require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name     = "techtrovert"
  s.version  = "0.9.0"
  s.author   = "Robert Hudson"
  s.email    = "techtrovert@gmail.com"
  s.homepage = "http://www.techtrovert.com"
  s.platform = Gem::Platform::RUBY
  s.summary  = "Helpful classes built by Techtrovert"
  s.files    = FileList["{test,lib,docs}/**/*"].exclude("rdoc").to_a
  s.require_path     = "lib"

  #s.test_file        = "test/ts_techtrovert.rb"
  s.has_rdoc         = false
  #s.extra_rdoc_files = ["README"]
  #s.add_dependency("capistrano", ">=2.1.0")

end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

