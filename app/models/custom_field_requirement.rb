# Used for Questions(CustomField) to LoanTypes(Options) associations which imply a required
# question for a given loan type.

class CustomFieldRequirement < ActiveRecord::Base
  belongs_to :custom_field
  belongs_to :option
end