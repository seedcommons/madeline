require 'rails_helper'

describe Organization, type: :model do

  before { seed_data }

  it 'has a valid factory' do
    expect(create(:organization)).to be_valid
  end

  it_should_behave_like 'notable'

end
