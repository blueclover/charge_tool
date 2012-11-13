require 'spec_helper'
feature "Creating a survey" do
  let!(:user) { Factory(:confirmed_user) }
  before do
    sign_in_as!(user)
  end
  scenario "Creating a survey with an attachment" do
    visit root_path
    click_link "New Survey"
    fill_in "Survey Name", with: "Test Survey"
    click_button "Create Survey"
    page.should have_content("Survey created")
    attach_file "File", "spec/fixtures/bookings1.csv"
    click_button "Process file"
    page.should have_content("File processed.")
    within(".span4") do
      page.should have_content("bookings1.csv")
    end
  end
end