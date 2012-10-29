require 'spec_helper'

feature 'Deleting users' do
  let!(:admin) { Factory(:admin) }
  let!(:user)  { Factory(:confirmed_user) }
  before do
    sign_in_as!(admin)
    visit '/'
    click_link "Admin"
    click_link "Users"
  end
  scenario "Deleting a user" do
    click_link user.email
    click_link "Delete User"
    page.should have_content("User has been deleted")
  end
end