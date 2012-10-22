require 'spec_helper'

describe Survey do

  let!(:user) { FactoryGirl.create(:user) }

  let(:survey) { User.first.surveys.build(name: "test survey") }

  subject { survey }

  it { should respond_to(:name) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:bookings) }
  its(:user) { should == user }

  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        Survey.new(user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "required attributes" do
    describe "when user_id is not present" do
      before { survey.user_id = nil }
      it { should_not be_valid }
    end

    describe "when name is not present" do
      before { survey.name = nil }
      it { should_not be_valid }
    end
  end

  describe "when name is too long" do
    before { survey.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "booking associations" do
    before { survey.save }
    before do
      FactoryGirl.create(:booking, survey: survey)
      FactoryGirl.create(:booking, survey: survey)
    end

    it "should have the right number of bookings" do
      survey.bookings.count.should == 2
    end

    it "should destroy associated bookings" do
      bookings = survey.bookings.dup
      survey.destroy
      bookings.should_not be_empty
      bookings.each do |booking|
        Booking.find_by_id(booking.id).should be_nil
      end
    end
  end
end
