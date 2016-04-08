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

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  validates :resource_type,
    inclusion: { in: Rolify.resource_types },
    allow_nil: true

  delegate :division, to: :resource

  scopify
end
