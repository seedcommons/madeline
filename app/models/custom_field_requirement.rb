# == Schema Information
#
# Table name: custom_field_requirements
#
#  amount          :decimal(, )      default(0.0), not null
#  custom_field_id :integer
#  id              :integer          not null, primary key
#  option_id       :integer
#

# Used for Questions(CustomField) to LoanTypes(Options) associations which imply a required
# question for a given loan type.

class CustomFieldRequirement < ActiveRecord::Base
  belongs_to :custom_field
  #belongs_to :option
  belongs_to :loan_type, class_name: 'Option', foreign_key: :option_id
end
