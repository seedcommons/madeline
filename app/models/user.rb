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
    owning_division_id
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
    profile && profile.has_system_access? && has_some_access?
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
