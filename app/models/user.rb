# == Schema Information
#
# Table name: users
#
#  created_at             :datetime         not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  id                     :integer          not null, primary key
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  profile_id             :integer
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_profile_id            (profile_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_a8794354f0  (profile_id => people.id)
#

class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :profile, class_name: Person
  delegate :division, :division=, to: :profile

  def name
    profile.try(:name)
  end

  def accessible_divisions
    # Todo: Confirm desired sort order.
    accessible_division_ids.map{ |id| Division.find_safe(id) }.compact
  end

  def accessible_division_ids
    # Todo: Confirm what other roles types to include here.
    all_ids = roll_referenced_division_ids.map do |id|
      division = Division.find_safe(id)
      division.self_and_descendants.pluck(:id) if division
    end
    all_ids.flatten.uniq.compact
  end

  def default_division
    Division.find(roll_referenced_division_ids.first)
  end

  def roll_referenced_division_ids
    roles.where(resource_type: :Division, name: [:admin]).pluck(:resource_id)
  end

end
