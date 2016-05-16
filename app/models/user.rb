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
    division_scope.resolve
  end

  def accessible_division_ids
    division_scope.accessible_ids
  end

  def division_scope
    DivisionPolicy::Scope.new(self, Division)
  end

  def default_division
    Division.find(default_division_id)
  end

  # For now, gives first preference to the division owning the user's profile, then looks for a role
  # associated division.
  # Todo: Confirm precise business rule desired here.  Will possibly depend on new data modeling.
  def default_division_id
    owning_division_id || division_scope.base_accessible_ids.first
  end

  def owning_division_id
    profile.try(:division_id)
  end

  def has_some_access?
    division_scope.base_accessible_ids.present?
  end

  # Require a user to have access to at least some division in order to login.
  # Note, this avoids needing to worry about a nil current_division in the controller logic.
  def active_for_authentication?
    has_some_access?
  end

  def inactive_message
    I18n.t("user.no_access") unless has_some_access?
  end
end
