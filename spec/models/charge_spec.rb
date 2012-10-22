require 'spec_helper'

describe Charge do
  let(:charge_type) { FactoryGirl.create(:charge_type) }
  let(:charge) { Charge.new(charge_type_id: charge_type.id) }

  subject { charge }

  it { should respond_to(:charge_type_id) }
  it { should respond_to(:charge_type) }
  it { should respond_to(:bookings) }
  it { should respond_to(:charge_aliases) }
  it { should respond_to(:score) }

  its(:score) { should == charge_type.score }

  it { should be_valid }

  describe "when charge_type is not present" do
    before { charge.charge_type = nil }
    it { should_not be_valid }
  end
end
