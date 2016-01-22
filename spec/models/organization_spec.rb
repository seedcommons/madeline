require 'rails_helper'

describe Organization, type: :model do

  it 'has a valid factory' do
    expect(create(:organization)).to be_valid
  end

  it_should_behave_like 'notable'

  it 'should set and get custom values' do
    create(:custom_field_set, :organization_fields)
    model = create(:organization)
    model.update_custom_value('is_recovered', true)
    fetched = Organization.find(model.id)
    # puts("fetched custom data: #{fetched.custom_data}")
    expect(fetched.custom_value('is_recovered')).to be true
  end

  it 'can filter by custom value' do
    create(:custom_field_set, :organization_fields)
    model = create(:organization)
    model.update_custom_value('is_recovered', true)
    expect(Organization.where_custom_value('is_recovered', 'true').count).to be 1
    expect(Organization.where_custom_value('is_recovered', 'false').count).to be 0
    model.update_custom_value('is_recovered', false)
    expect(Organization.where_custom_value('is_recovered', 'true').count).to be 0
    expect(Organization.where_custom_value('is_recovered', 'false').count).to be 1
  end

  it 'should handle inherited custom field sets' do
    root_division = Division.root
    sub_division = create(:division, parent: root_division, internal_name: 'sub')
    field_set = create(:custom_field_set, division: root_division, internal_name: Organization.name)
    create(:custom_field, custom_field_set: field_set, internal_name: 'root_string', data_type: 'string')
    org = create(:organization, division: sub_division)
    org.update_custom_value('root_string', 'root_value')
    fetched = Organization.find(org.id)
    expect(fetched.custom_value('root_string')).to eq 'root_value'

    sub_field_set = create(:custom_field_set, division: sub_division, internal_name: Organization.name)
    create(:custom_field, custom_field_set: sub_field_set, internal_name: 'sub_string', data_type: 'string')
    expect { org.custom_value('root_string') }.to raise_error(RuntimeError)

    org.update_custom_value('sub_string', 'sub_value')
    fetched = Organization.find(org.id)
    expect(fetched.custom_value('sub_string')).to eq 'sub_value'
  end

end
