require 'rails_helper'

describe Organization, type: :model do

  it 'has a valid factory' do
    expect(create(:organization)).to be_valid
  end

  it_should_behave_like 'notable'

  it 'should set and get custom values' do
    create(:custom_field_set, :organization_fields)
    model = create(:organization)
    model.update_value('is_recovered', true)
    fetched = Organization.find(model.id)
    # puts("fetched custom data: #{fetched.custom_data}")
    expect(fetched.get_value('is_recovered')).to be true
  end

  it 'can filter by custom value' do
    create(:custom_field_set, :organization_fields)
    model = create(:organization)
    model.update_value('is_recovered', true)
    expect(Organization.where_custom_value('is_recovered', 'true').count).to be 1
    expect(Organization.where_custom_value('is_recovered', 'false').count).to be 0
    model.update_value('is_recovered', false)
    expect(Organization.where_custom_value('is_recovered', 'true').count).to be 0
    expect(Organization.where_custom_value('is_recovered', 'false').count).to be 1
  end

end
