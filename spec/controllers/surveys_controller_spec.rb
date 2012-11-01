require 'spec_helper'
include Devise::TestHelpers

describe SurveysController do
  let(:user) do
    user = Factory(:user)
    user.confirm!
    user
  end

  let(:survey) { Factory(:survey) }

  context "standard users" do

    it "cannot access the show action without permission" do
      sign_in(:user, user)
      get :show, :id => survey.id
      response.should redirect_to(root_path)
      flash[:alert].should eql("The survey you were looking " +
                                   "for could not be found.")
    end

  #  { "new" => "get",
  #    "create" => "post",
  #    "edit" => "get",
  #    "update" => "put",
  #    "destroy" => "delete" }.each do |action, method|
  #    it "cannot access the #{action} action" do
  #      sign_in(:user, user)
  #      send(method, action.dup, :id => survey.id)
  #      response.should redirect_to(root_path)
  #      flash[:alert].should eql("You must be an admin to do that.")
  #    end
  #  end
  end

  it "displays an error for a missing survey" do
    sign_in(:user, user)
    get :show, :id => "not-here"
    response.should redirect_to(root_path)
    message = "The survey you were looking for could not be found."
    flash[:alert].should eql(message)
  end

end
