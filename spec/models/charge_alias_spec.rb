require 'spec_helper'

describe ChargeAlias do
  let!(:charge_type) { FactoryGirl.create(:charge_type) }
  let!(:charge) { FactoryGirl.create(:charge, charge_type_id: charge_type.id) }
  let(:charge_alias) { ChargeAlias.new(alias: "187a", charge_id: charge.id) }

  subject { charge_alias }

  it { should respond_to(:charge_id) }
  it { should respond_to(:alias) }
  it { should respond_to(:charge) }
  it { should respond_to(:score) }
  its(:charge) { should == charge }
  its(:score)  { should == charge_type.score }


  it { should be_valid }

  describe "when alias is not present" do
    before { charge_alias.alias = nil }
    it { should_not be_valid }
  end
end
