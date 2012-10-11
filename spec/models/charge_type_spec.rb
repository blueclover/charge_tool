require 'spec_helper'

describe ChargeType do
  let(:charge_type) { ChargeType.new(score: 0) }

  subject { charge_type }

  it { should respond_to(:score) }
  it { should respond_to(:charges) }

  it { should be_valid }

  describe "when score is not present" do
    before { charge_type.score = nil }
    it { should_not be_valid }
  end
end
