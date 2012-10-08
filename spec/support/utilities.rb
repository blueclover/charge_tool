include ApplicationHelper

def fill_in_valid_user_info
  fill_in "Name",         with: "Example User"
  fill_in "Email",        with: "user@example.com"
  fill_in "Password",     with: "foobar"
  fill_in "Confirm Password", with: "foobar"
end

def fill_signin_fields(user)
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # tutorial had following line for when not using Capybara:
  cookies[:remember_token] = user.remember_token
  #session[:user_id] = user.id  # <- this doesn't work
end

def sign_in(user)
  visit signin_path
  fill_signin_fields user
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