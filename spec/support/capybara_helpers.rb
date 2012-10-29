module CapybaraHelpers
  def assert_no_link_for(text)
    page.should_not(have_css("a", :text => text),
                    "Expected not to see the #{text.inspect} link, but did.")
  end
  def assert_link_for(text)
    page.should(have_css("a", :text => text),
                "Expected to see the #{text.inspect} link, but did not.")
  end
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-success', text: message)
  end
end

RSpec.configure do |config|
  config.include CapybaraHelpers, :type => :request
end