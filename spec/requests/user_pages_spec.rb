require 'spec_helper'

describe "User Pages" do
  subject { page }

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: full_title(user.name)) }
  end

  describe "registration page" do
    before { visit register_path }

    it { should have_selector('h1',    text: 'Register') }
    it { should have_selector('title', text: full_title('Register')) }
  end

  describe "register new user" do

    before { visit register_path }

    let(:submit) { "Create account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
      describe "after submission" do
        before { click_button submit }

        it { should have_selector('title', text: full_title('Register')) }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before { fill_in_valid_user_info }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_success_message('Registration') }
        it { should have_link('Sign out') }
      end
    end
  end
end
