require 'rails_helper'

describe Person, type: :model do

  it 'has a valid factory' do
    expect(create(:person)).to be_valid
  end

  it_should_behave_like 'notable'


end
