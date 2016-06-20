# == Schema Information
#
# Table name: people
#
#  birth_date              :date
#  city                    :string
#  contact_notes           :text
#  country_id              :integer
#  created_at              :datetime         not null
#  division_id             :integer
#  email                   :string
#  fax                     :string
#  first_name              :string
#  has_system_access       :boolean          default(FALSE), not null
#  id                      :integer          not null, primary key
#  last_name               :string
#  legal_name              :string
#  name                    :string
#  neighborhood            :string
#  postal_code             :string
#  primary_organization_id :integer
#  primary_phone           :string
#  secondary_phone         :string
#  state                   :string
#  street_address          :text
#  tax_no                  :string
#  updated_at              :datetime         not null
#  website                 :string
#
# Indexes
#
#  index_people_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_20168ebb0e  (primary_organization_id => organizations.id)
#  fk_rails_7aab1f72a5  (division_id => divisions.id)
#  fk_rails_fdfb048ae6  (country_id => countries.id)
#

#
# Person represents the contact and relationship information for a loan agent or co-op members,
# and is distinguished from User which represents access and authentication information.
# A valid User must reference a Person record with 'has_system_access' in order to login into the
# system.  When a Person record is created or updated with 'has_system_access' true, then an
# associated User record is created with the access granted based on the transient
# 'owning_division_role' attribute and 'password'/'password_confirmation' attributes.
#

class Person < ActiveRecord::Base
  include Contactable  # this is a placeholder concern for the shared aspects between Organization and People.
  include Notable
  include MediaAttachable

  VALID_DIVISION_ROLES = %i(member admin)

  belongs_to :division
  belongs_to :country
  belongs_to :primary_organization, class_name: 'Organization'

  has_many :primary_agent_loans,   class_name: 'Loan', foreign_key: :primary_agent_id
  has_many :secondary_agent_loans, class_name: 'Loan', foreign_key: :secondary_agent_id
  has_many :representative_loans,  class_name: 'Loan', foreign_key: :representative_id

  has_one :user, foreign_key: :profile_id, autosave: true, dependent: :destroy

  validates :division_id, presence: true
  validates :first_name, presence: true

  validate :division_role_valid
  validate :user_valid

  # Transient attributes to facilitate user management
  attr_writer :owning_division_role
  attr_accessor :password, :password_confirmation

  before_save :update_full_name
  before_save :update_user
  after_save :handle_roles
  after_save :clean_up_passwords

  scope :by_name, -> { order("LOWER(first_name), LOWER(last_name)") }

  # Lazy evaluation getter
  def owning_division_role
    @owning_division_role = resolve_owning_division_role unless defined? @owning_division_role
    @owning_division_role
  end

  def owning_division_role_label
    label_key = owning_division_role || 'none'
    I18n.t("simple_form.options.person.owning_division_role.#{label_key}")
  end

  private

  def update_full_name
    self.name = "#{first_name} #{last_name}"
  end

  def resolve_owning_division_role
    if user
      role = user.roles.find_by(resource_type: 'Division', resource_id: division_id)
      return role.name.to_sym if role
    end
    nil
  end

  def user_required?
    has_system_access?
  end

  def division_role_valid
    if has_system_access? && (owning_division_role.blank? ||
      !VALID_DIVISION_ROLES.include?(owning_division_role.to_sym))
      errors.add(:owning_division_role, I18n.t("people.shared.invalid_division_role"))
    end
  end

  # Delegates validation to the automatically created user instance.
  def user_valid
    if user_required?
      update_user
      unless user.valid?
        user.errors.each do |error,message|
          errors.add(error,message)
        end
      end
    end
  end

  def update_user
    if user_required?
      if user
        # Updates fields on existing user if previously created
        user.email = self.email
        if password.present?
          user.password = self.password
          user.password_confirmation = self.password_confirmation
        end
      else
        build_user(
          email: email,
          password: password,
          password_confirmation: password_confirmation
        )
      end
    end
  end

  def handle_roles
    return unless has_system_access # not expected, but broken form display logic was allowing
    old_role = resolve_owning_division_role
    new_role = owning_division_role.present? ? owning_division_role.to_sym : nil
    # Invalid roles expected to rejected by validation rules. but avoid cryptic error just in case.
    raise "Unexpected division role: #{new_role}" if new_role && !VALID_DIVISION_ROLES.include?(new_role)
    if old_role != new_role
      # For now safest to remove all other roles.  May need to revisit if more complexity
      # is allowed around permissions in the future.
      user.roles.destroy_all
      user.add_role new_role, division if new_role
    end
  end

  def clean_up_passwords
    self.password = self.password_confirmation = nil
  end

end
