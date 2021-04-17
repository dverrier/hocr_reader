require_relative 'lib/hocr_reader/version'

Gem::Specification.new do |spec|
  spec.name          = "hocr_reader"
  spec.version       = HocrReader::VERSION
  spec.authors       = ["David Verrier"]
  spec.email         = ["dverrier@gmail.com"]

  spec.summary       = %q{Load HOCR format and render in Ruby objects}
  spec.description   = %q{Read HOCR and present Ruby objects}
  spec.homepage      = "https://github.com/dverrier/hocr_reader"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = 'https://rubygems.org'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dverrier/hocr_reader"
  spec.metadata["changelog_uri"] = "https://github.com/dverrier/hocr_reader"
  spec.add_development_dependency('minitest')
  spec.add_dependency "nokogiri", "~> 1.11.1"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
