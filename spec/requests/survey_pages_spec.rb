require 'spec_helper'

describe "Survey pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "survey creation" do

    let(:submit) { "Create Survey" }

    before { visit new_survey_path }

    describe "with invalid information" do

      it "should not create a survey" do
        expect { click_button submit }.not_to change(Survey, :count)
      end

      describe "error messages" do
        before { click_button submit }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before { fill_in "Survey Name", with: "Example Survey" }

      it "should create a survey" do
        expect { click_button submit }.to change(Survey, :count).by(1)
      end

      describe "after saving the survey" do
        before { click_button submit }

        it { should have_selector('title', text: "Example Survey") }
        it { should have_success_message('Survey') }
      end
    end
  end
end