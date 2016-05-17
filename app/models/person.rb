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

  # JE Todo 3776: Confirm better way to match up devise handled password validation with these fields
  PASSWORD_LENGTH = 8..72
  VALID_DIVISION_ROLES = [:member, :admin]
  # VALID_ROLE_VALUES = [nil, '', 'member', 'admin']

  belongs_to :division
  belongs_to :country
  belongs_to :primary_organization, class_name: 'Organization'

  has_many :primary_agent_loans,   class_name: 'Loan', foreign_key: :primary_agent_id
  has_many :secondary_agent_loans, class_name: 'Loan', foreign_key: :secondary_agent_id
  has_many :representative_loans,  class_name: 'Loan', foreign_key: :representative_id

  has_one :user, foreign_key: :profile_id

  validates :division_id, presence: true
  validates :first_name, presence: true

  # validates :password, presence: true, if: -> { Division.root.present? && Division.root_id != id }
  # validates_presence_of :password, if: :password_required?
  # validates_confirmation_of :password, if: :password_required?
  # validates_length_of       :password, within: PASSWORD_LENGTH, allow_blank: true

  # validates_presence_of :email, if: -> { owning_division_role.present? }
  # validates_inclusion_of :owning_division_role, in: VALID_ROLE_VALUES
  validate :division_role_valid
  validate :associated_user_valid


  # Transient attributes to fascilitate user managment
  # attr_writer :has_online_access
  attr_writer :owning_division_role
  attr_accessor :password, :password_confirmation

  after_save :update_associated_user
  #JE Todo 3776: Confirm if there is a clean way to defer this init unless we're expecting to edit
  # after_initialize :assign_transient_user_attributes

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

  def create_associated_user
    # @associated_user = User.create!(
    #   email: email,
    #   password: password,
    #   password_confirmation: password_confirmation,
    #   profile_id: id
    # )
    @associated_user = new_associated_user
    @associated_user.save!
    @associated_user
  end

  def new_associated_user
    User.new(
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      profile_id: id
    )
  end

  def associated_user
    return @associated_user if defined? @associated_user
    @associated_user = User.find_by(profile_id: id)
  end

  # def assign_transient_user_attributes
  #   # @has_online_access = has_online_access
  #   @owning_division_role = resolve_owning_division_role
  # end

  def has_online_access
    has_associated_user?
  end

  def owning_division_role
    @owning_division_role = resolve_owning_division_role unless defined? @owning_division_role
    @owning_division_role
  end

  def resolve_owning_division_role
    user = associated_user
    if user
      role = user.roles.find_by(resource_type: 'Division', resource_id: division_id)
      return role.name.to_sym if role
    end
    nil
  end

  # Validate password if role being assigned for first time or password values provided
  def password_required?
    owning_division_role.present? && !associated_user || password.present? || password_confirmation.present?
  end

  def division_role_valid
    if owning_division_role.present? && !VALID_DIVISION_ROLES.include?(owning_division_role.to_sym)
      errors.add(:owning_division_role, I18n.t("people.invalid_division_role"))
    end
  end

  def associated_user_valid
    if password_required? #owning_division_role.present? && !associated_user
      user = new_associated_user
      unless user.valid?
        user.errors.each do |error,message|
          puts "error: #{error} - #{message}"
          errors.add(error,message)
        end
      end
    end
  end

  def update_associated_user
    old_role = resolve_owning_division_role
    new_role = owning_division_role.present? ? owning_division_role.to_sym : nil
    # raise "Unexpected division role: #{new_role}" unless VALID_DIVISION_ROLES.include?(new_role)
    puts "new owning division role: #{new_role}"
    if new_role != nil || old_role != nil
      user = associated_user
      if user
        # Check for needed updates to an existing User record.
        if password.present?
          user.update(password: password, password_confirmation: password_confirmation)
        end
        if user.email != email
          # Mirror email onto user record from person record.
          user.update(email: email)
        end
      end
      user = create_associated_user unless user
      puts "update assoc - old role: #{old_role}, new role: #{new_role}"  #fixme
      if old_role != new_role
        puts "apply change in role"
        user.remove_role old_role, division if old_role
        user.add_role new_role, division if new_role
      end
      clean_up_passwords
    end
  end

  def clean_up_passwords
    self.password = self.password_confirmation = nil
  end


  # def update_associated_user
  #   if @has_online_access || has_online_access
  #     user = ensured_associated_user
  #     # fixme: handle subsequent password update
  #     old_role = owning_division_role
  #     puts "update assoc - old role: #{old_role}, new role: #{@owning_division_role}"  #fixme
  #     if old_role != @owning_division_role
  #       puts "apply change in role"
  #       user.roles.delete(resource_type: 'Division', resource_id: division_id)
  #       if owning_division_role != :none
  #         user.add_role @owning_division_role, division
  #       end
  #     end
  #   end
  # end

end
