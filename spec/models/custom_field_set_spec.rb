require 'rails_helper'

describe CustomFieldSet, :type => :model do

  it_should_behave_like 'translatable', ['label']

  it 'has a valid factory' do
    expect(create(:custom_field_set)).to be_valid
  end

end

