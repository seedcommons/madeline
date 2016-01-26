require 'rails_helper'

describe CustomField, :type => :model do

  it_should_behave_like 'translatable', ['label']

  it 'has a valid factory' do
    expect(create(:custom_field)).to be_valid
  end
end
