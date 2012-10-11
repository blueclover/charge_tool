require 'spec_helper'

describe Booking do

  let(:booking) { Booking.new(zip_code: "05301", booking_date: 5.days.ago) }

  subject { booking }

  it { should respond_to(:zip_code) }
  it { should respond_to(:booking_date) }
  it { should respond_to(:booking_details) }
  it { should respond_to(:charges) }
  it { should respond_to(:score) }

  it { should be_valid }

  describe "charge associations" do
    before { booking.save }
    let!(:type1) { FactoryGirl.create(:charge_type, score: 5) }
    let!(:type2) { FactoryGirl.create(:charge_type, score: 12) }
    let!(:charge1) { FactoryGirl.create(:charge, charge_type: type1) }
    let!(:charge2) { FactoryGirl.create(:charge, charge_type: type2) }
    before do
      FactoryGirl.create(:booking_detail, booking: booking,
                         charge: charge1)
      FactoryGirl.create(:booking_detail, booking: booking,
                         charge: charge2)
    end
    it "should yield the right score" do
      booking.score.should == 13
    end
    it "should have the right charges in the right order" do
      booking.charges.should == [charge1, charge2]
    end
    it "should destroy associated booking_details" do
      booking_details = booking.booking_details.dup
      booking.destroy
      booking_details.should_not be_empty
      booking_details.each do |detail|
        BookingDetail.find_by_id(detail.id).should be_nil
      end
    end
  end
end
