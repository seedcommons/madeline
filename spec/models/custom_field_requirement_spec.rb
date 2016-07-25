require 'rails_helper'

describe CustomFieldRequirement, type: :model do

  it 'has a valid factory' do
    expect(create(:custom_field_requirement)).to be_valid
  end

end
