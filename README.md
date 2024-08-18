# TestCriteria

The library allows you to split unit tests into separate pieces.
First, contains expectations/assertions and related code snippets.
Second, keeps all variables, database preconditions.
This gem is focused on second part. You'll get the way to strucuture and reuse
similar prerequsites in diffent test cases.
Also you find your test cleaner, easier to read, and maintain.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add test_criteria

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install test_criteria

## Usage

1. Configure your test suite
```ruby
# test_hepler.rb or spec_helper.rb

# Define new directory for keeping test cases' context definitions
Dir["#{Rails.root.join('test/contexts')}/*.rb"].each { |file| require file }

# Optionally add global support of FactoryBot methods or additional helpers
TestCriteria::ContextDefinition.extend FactoryBot::Syntax::Methods
```

2. Add context
```ruby
# contexts/mfa_context.rb
TestCriteria.define do
  context(:mfa) do |context|
    context.db do |d|
      context.user = create :user
    end

    context.user_code = '465739'

    context.flash do |f|
      f.login_success = 'Logged in successfully'
      f.wrong_code = 'Wrong MFA code. Please try again'
      f.mfa_enabled = 'Multi-factor authentication enabled'
      f.mfa_disabled = 'Multi-factor authentication disabled'
    end

    context.account_page do |a|
      a.enable = 'Enable MFA'
      a.disable = 'Disable MFA'
    end

    context.setup_page do |p|
      p.header = 'Setup Multi-Factor Authentication'
      p.sub_header = 'Use your multi-factor authentication app to scan the QR code'
      p.label = 'Enter 6-digit code from your multi-factor authenticator app.'
      p.input_selector = 'input#mfa_code'
      p.input_id = 'mfa_code'
      p.image_selector = 'img[alt="Authentication QR code"]'
      p.cannot_scan_link_selector = 'a#manual_setup'
      p.cannot_scan_label = 'Enter the following into your app:'
      p.account_name = "Account name: #{context.user.google_label}"
      p.code = "Secret key: #{context.user.google_secret_value}"
      p.confirm = 'Confirm'
    end

    context.session_page do |s|
      s.header = 'Multi-Factor Authentication'
      s.sub_header = 'Enter 6-digit code from your multi-factor authenticator app.'
      s.input_id = 'mfa_code'
      s.confirm = 'Confirm'
    end
  end
end
```

3. Write tests
```ruby
require 'test_helper'

class MfaSetupTest < ApplicationSystemTestCase
  # Load your context
  let(:given) { TestCriteria[:mfa] }

  feature 'user can enable MFA' do
    before do
      # create records in database
      given.db
      login(given.user)
    end

    scenario 'Account > Enable MFA' do
      visit root_path
      click_link 'Account'
      account_page = given.account_page
      setup_page = given.setup_page

      click_link account_page.enable
      _(page).must_have_content setup_page.header
      _(page).must_have_content setup_page.sub_header
      _(page).must_have_content setup_page.label
      _(page).must_have_selector setup_page.input_selector
      _(page).must_have_selector setup_page.image_selector

      page.find(setup_page.cannot_scan_link_selector).click
      _(page).must_have_content setup_page.code
      _(page).must_have_content setup_page.account_name
      _(page).must_have_content setup_page.cannot_scan_label

      click_button setup_page.confirm
      _(page).must_have_content given.flash.wrong_code
      _(page).must_be_accessible

      User.any_instance.stubs(:google_authentic?).with(given.user_code).returns(true)
      fill_in setup_page.input_id, with: given.user_code

      _(page).must_have_content given.flash.mfa_enabled
      _(page.current_path).must_equal account_path

      click_link account_page.disable
      _(page).must_have_content given.flash.mfa_disabled
      _(page.current_path).must_equal account_path
      _(page).must_have_content account_page.enable
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andriy-baran/test_criteria. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/andriy-baran/test_criteria/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TestCriteria project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/andriy-baran/test_criteria/blob/master/CODE_OF_CONDUCT.md).
