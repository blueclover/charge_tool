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
end

def sign_in_as!(user)
  visit new_user_session_path
  fill_signin_fields user
end

def define_permission!(user, action, thing)
  Permission.create!(:user => user,
                     :action => action,
                     :thing => thing)
end