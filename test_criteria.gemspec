# frozen_string_literal: true

require_relative 'lib/test_criteria/version'

Gem::Specification.new do |spec|
  spec.name = 'test_criteria'
  spec.version = TestCriteria::VERSION
  spec.authors = ['Andrii Baran']
  spec.email = ['andriy.baran.v@gmail.com']

  spec.summary = 'Create preconditions and manage criteria for the unit test'
  spec.description = 'Keep variables, database setup in separate file'
  spec.homepage = 'https://github.com/andriy-baran/test_criteria'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/andriy-baran/test_criteria'
  spec.metadata['changelog_uri'] = 'https://github.com/andriy-baran/test_criteria/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
