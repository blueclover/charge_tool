require 'spec_helper'

describe BookingDetail do
  let!(:booking)     { FactoryGirl.create(:booking) }
  let!(:charge)      { FactoryGirl.create(:charge) }

  let!(:booking_detail) do
    booking.booking_details.build(rank: 1, charge_id: charge.id)
  end

  subject { booking_detail }

  it { should respond_to(:booking_id) }
  it { should respond_to(:rank) }
  it { should respond_to(:charge_id) }
  it { should respond_to(:booking) }
  it { should respond_to(:charge) }
  it { should respond_to(:score) }
  its(:booking) { should == booking }
  its(:charge)  { should == charge }
  its(:score)   { should == charge.score }

  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to booking_id" do
      expect do
        BookingDetail.new(booking_id: booking.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "required attributes" do
    describe "when booking_id is not present" do
      before { booking_detail.booking_id = nil }
      it { should_not be_valid }
    end

    describe "when rank is not present" do
      before { booking_detail.rank = nil }
      it { should_not be_valid }
    end

    describe "when charge_id is not present" do
      before { booking_detail.charge_id = nil }
      it { should_not be_valid }
    end
  end
end