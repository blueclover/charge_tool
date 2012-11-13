require 'spec_helper'

describe UserConfiguration do

  let!(:user)  { FactoryGirl.create(:confirmed_user) }

  let!(:user_configuration) do
    user.build_user_configuration
  end

  subject { user_configuration }

  it { should respond_to(:user_id) }
  it { should respond_to(:zip_code_field_name) }
  it { should respond_to(:city_field_name) }
  it { should respond_to(:state_field_name) }
  it { should respond_to(:charge_field_prefix) }
  it { should respond_to(:user) }
  its(:user) { should == user }

  it { should be_valid }

  describe "required attributes" do
    describe "when charge_field_prefix is not present" do
      before { user_configuration.charge_field_prefix = nil }
      it { should_not be_valid }
    end
  end

end