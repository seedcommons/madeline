require 'rails_helper'

describe CustomFieldSet, :type => :model do

  # note, was getting an "Language code: EN not found" error without calling the seed_data here,
  # but not sure why this class is different from others like 'Note'
  before { seed_data }

  it_should_behave_like 'translatable', ['label']

  it 'has a valid factory' do
    puts("lang count: #{Language.count}")
    expect(create(:custom_field_set)).to be_valid
  end

end

