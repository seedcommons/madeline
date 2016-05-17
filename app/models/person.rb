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

class Person < ActiveRecord::Base
  include Contactable  # this is a placeholder concern for the shared aspects between Organization and People.
  include Notable
  include MediaAttachable

  VALID_DIVISION_ROLES = [:member, :admin]

  belongs_to :division
  belongs_to :country
  belongs_to :primary_organization, class_name: 'Organization'

  has_many :primary_agent_loans,   class_name: 'Loan', foreign_key: :primary_agent_id
  has_many :secondary_agent_loans, class_name: 'Loan', foreign_key: :secondary_agent_id
  has_many :representative_loans,  class_name: 'Loan', foreign_key: :representative_id

  has_one :user, foreign_key: :profile_id, autosave: true

  validates :division_id, presence: true
  validates :first_name, presence: true

  validate :division_role_valid
  validate :user_valid

  # Transient attributes to fascilitate user managment
  attr_writer :owning_division_role
  attr_accessor :password, :password_confirmation

  before_save :update_user
  after_save :handle_roles
  after_save :clean_up_passwords

  #JE todo: this is a placeholder until we implement an automatic update or decide on different handling around the full name
  def name
    "#{first_name} #{last_name}"
  end

  def has_associated_user?
    User.where(profile_id: id).any?
  end

  def ensured_associated_user
    create_associated_user unless associated_user
    associated_user
  end

  def has_online_access
    has_associated_user?
  end

  # Lazy evaluation getter
  def owning_division_role
    @owning_division_role = resolve_owning_division_role unless defined? @owning_division_role
    @owning_division_role
  end

  def owning_division_role_label
    label_key = owning_division_role || 'none'
    I18n.t("people.roles.#{label_key}")
  end

  def resolve_owning_division_role
    if user
      role = user.roles.find_by(resource_type: 'Division', resource_id: division_id)
      return role.name.to_sym if role
    end
    nil
  end

  def user_required?
    owning_division_role.present? || password.present? || password_confirmation.present?
  end

  def division_role_valid
    if owning_division_role.present? && !VALID_DIVISION_ROLES.include?(owning_division_role.to_sym)
      errors.add(:owning_division_role, I18n.t("people.shared.invalid_division_role"))
    end
  end

  # Delegates validation to the automatically created user instance.
  def user_valid
    # JE Todo: backend policy restriction of updates to user fields on person record
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
        # auto_build_user
        build_user(
          email: email,
          password: password,
          password_confirmation: password_confirmation
        )
      end
    end
  end

  def handle_roles
    old_role = resolve_owning_division_role
    new_role = owning_division_role.present? ? owning_division_role.to_sym : nil
    raise "Unexpected division role: #{new_role}" if new_role && !VALID_DIVISION_ROLES.include?(new_role)
    # puts "update assoc - old role: #{old_role}, new role: #{new_role}"
    if old_role != new_role
      # puts "apply change in role"
      user.remove_role old_role, division if old_role
      user.add_role new_role, division if new_role
    end
  end

  def clean_up_passwords
    self.password = self.password_confirmation = nil
  end

end
