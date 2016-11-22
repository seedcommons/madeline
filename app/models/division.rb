# == Schema Information
#
# Table name: divisions
#
#  accent_fg_color    :string
#  accent_main_color  :string
#  banner_bg_color    :string
#  banner_fg_color    :string
#  created_at         :datetime         not null
#  currency_id        :integer
#  custom_data        :json
#  description        :text
#  id                 :integer          not null, primary key
#  internal_name      :string
#  logo_content_type  :string
#  logo_file_name     :string
#  logo_file_size     :integer
#  logo_text          :string
#  logo_updated_at    :datetime
#  name               :string
#  notify_on_new_logs :boolean          default(FALSE)
#  organization_id    :integer
#  parent_id          :integer
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_divisions_on_currency_id      (currency_id)
#  index_divisions_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_648c512956  (organization_id => organizations.id)
#  fk_rails_99cb2ea4ed  (currency_id => currencies.id)
#

class Division < ActiveRecord::Base
  include DivisionBased

  has_closure_tree dependent: :restrict_with_exception
  resourcify
  alias_attribute :super_division, :parent

  normalize_attributes :logo_text, :banner_fg_color, :banner_bg_color, :accent_main_color, :accent_fg_color

  has_many :loans, dependent: :restrict_with_exception
  has_many :people, dependent: :restrict_with_exception
  has_many :organizations, dependent: :restrict_with_exception

  has_many :loan_question_sets, dependent: :destroy
  has_many :option_sets, dependent: :destroy

  # Bug in closure_tree requires these 2 lines (https://github.com/mceachen/closure_tree/issues/137)
  has_many :self_and_descendants, through: :descendant_hierarchies, source: :descendant
  has_many :self_and_ancestors, through: :ancestor_hierarchies, source: :ancestor

  belongs_to :parent, class_name: 'Division'

  # Note the requirements around a single currency or a 'default currency' per division has been in
  # flux. Should probably rename the DB column to 'default_currency_id' once definitively settled.
  belongs_to :default_currency, class_name: 'Currency', foreign_key: 'currency_id'
  alias_attribute :default_currency_id, :currency_id

  belongs_to :organization  # the organization which represents this loan agent division

  # Logo will be resized to 65px height on screen, but for higher pixel density devices we don't want to
  # go below 3x that. Wide logos are acceptable, up to about 280px logical.
  has_attached_file :logo, styles: { banner: "840x195>" }
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\z/

  validates :name, presence: true
  validates :parent, presence: true, if: -> { Division.root.present? && Division.root_id != id }

  scope :by_name, -> { order("LOWER(divisions.name)") }

  def self.root_id
    result = root.try(:id)
    logger.info("division root.id: #{result}")
    result
  end

  # interface compatibility with other models
  def division
    self
  end

  def has_logo_text?
    logo_text.present?
  end

  def has_noncascading_dependents?
    Division.where(parent: self).present? ||
      Organization.where(division: self).present? ||
      Loan.where(division: self).present?  ||
      Person.where(division: self).present?
  end

  def users
    people.where(has_system_access: true)
  end
end
