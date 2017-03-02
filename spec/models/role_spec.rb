# == Schema Information
#
# Table name: roles
#
#  created_at    :datetime
#  id            :integer          not null, primary key
#  name          :string           not null
#  resource_id   :integer
#  resource_type :string
#  updated_at    :datetime
#
# Indexes
#
#  index_roles_on_name                                    (name)
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id) UNIQUE
#

require 'rails_helper'

describe Role, type: :model do
  it 'has a valid factory' do
    expect(create(:role)).to be_valid
  end
end
