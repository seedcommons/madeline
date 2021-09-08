#
# In order to access the system, profile must reference a Person record with 'has_system_access' true.
# More information about the distinction between User and Person can be found under person.rb.

class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :profile, class_name: 'Person'
  delegate :division, :division=, to: :profile

  def name
    profile.try(:name)
  end

  def accessible_divisions
    Division.where(id: accessible_division_ids)
  end

  # This merges in child divisions of the divisions for which a user has been specifically
  # granted access.
  def accessible_division_ids
    base_ids = roles.where(resource_type: :Division, name: [:member, :admin]).pluck(:resource_id).uniq
    all_ids = base_ids.map do |id|
      division = Division.find_by(id: id)
      division.self_and_descendants.pluck(:id) if division
    end
    all_ids.flatten.uniq.compact
  end

  def default_division
    Division.find(default_division_id)
  end

  # For now, gives first preference to the division owning the user's profile, then looks for a role
  # associated division.
  # Todo: Confirm precise business rule desired here.  Will possibly depend on new data modeling.
  def default_division_id
    owning_division_id
  end

  def owning_division_id
    profile.try(:division_id)
  end

  # Require a user to have access to at least some division in order to login.
  # Note, this avoids needing to worry about a nil selected_division in the controller logic.
  def active_for_authentication?
    profile && profile.has_system_access? && self.accessible_division_ids.present?
  end

  def inactive_message
    if !profile
      I18n.t("user.no_person")
    elsif !profile.has_system_access?
      I18n.t("user.no_system_access")
    else
      I18n.t("user.no_division_access")
    end
  end
end
