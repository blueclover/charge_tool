require 'spec_helper'
feature "Viewing surveys" do
  let!(:user) { Factory(:confirmed_user) }
  let!(:survey) { Factory(:survey, user: user) }
  before do
    sign_in_as!(user)
    define_permission!(user, :view, survey)
  end
  scenario "Listing all surveys" do
    visit root_path
    click_link survey.name
    page.current_url.should == survey_url(survey)
  end
end