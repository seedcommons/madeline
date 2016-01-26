# == Schema Information
#
# Table name: divisions
#
#  created_at      :datetime         not null
#  currency_id     :integer
#  description     :text
#  id              :integer          not null, primary key
#  internal_name   :string
#  name            :string
#  organization_id :integer
#  parent_id       :integer
#  updated_at      :datetime         not null
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
  has_closure_tree
  alias_attribute :super_division, :parent


  has_many :loans   #, dependent: :destroy  - should probably require owned models to be explicitly deleted
  has_many :people
  has_many :organizations


  belongs_to :parent, class_name: 'Division'
  belongs_to :default_currency, class_name: 'Currency'
  belongs_to :organization  # the organization which represents this loan agent division

  validates :name, presence: true
  validates :parent, presence: true, if: -> { Division.root.present? && Division.root_id != id }


  # Note: the closure_tree automatically provides a Division.root class method which returns the
  # first Division with a null parent_id ordered by id.


  # Note, this code is useful for debugging unit tests with elusive Division.root dependencies
  #
  # AUTOCREATE_ROOT = false
  #
  # def self.root
  #   if AUTOCREATE_ROOT
  #     ensured_root
  #   else
  #     # result = super.root
  #     # how to directly call 'super' for modules?
  #     result = roots.first
  #     unless result
  #       # puts caller
  #       puts "unexpectedly missing root Division - failing"
  #       raise "unexpectedly missing root Division"
  #     end
  #     result
  #   end
  # end
  #
  # # ensures that a root division exists and returns it
  # def self.ensured_root
  #   # create on demand if not present for convenience of blank db's and test cases
  #   # Division.find_by(internal_name: root_internal_name) || Division.create(internal_name: root_internal_name, name:'Root Division')
  #   fetched = roots  # closure_tree method
  #   # todo: figure out best way to make sure Rails.logger is displayed from tests
  #   puts "unexpectedly non-unique root Division - count: #{fetched.size}"  if fetched.size > 1
  #   result = fetched.first
  #   unless result
  #     puts "unexpectedly missing root Division - autocreating"
  #     puts caller
  #     result = Division.create(name:'Root Division')
  #   end
  #   result
  # end


  def self.root_id
    result = root.try(:id)
    logger.info("division root.id: #{result}")
    result
  end


  # note, current 'accessible' logic is a placeholder until migrate updated to
  # deduce most appropriate division owner of people and orgs, and loan specific visibility
  # access control model implemented

  def accessible_organizations
    # for now hack access to current or root division owned entities
    if root?
      Organization.all
    else
      Organization.where(division_id: [id, Division.root_id]).order(:name)
    end
  end

  def accessible_people
    # for now hack access to current or root division owned entities
    if root?
      Person.all
    else
      Person.where(division_id: [id, Division.root_id]).order(:last_name)
    end
  end

  def accessible_loans
    if root?
      Loan.all
    else
      Loan.where(division_id: [id, Division.root_id]).order(signing_date: :desc)
    end
  end

  def loans_count
    loans.size
  end

end
