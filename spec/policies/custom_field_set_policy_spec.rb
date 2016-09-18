require 'rails_helper'

describe CustomFieldSetPolicy do
  it_should_behave_like 'base_policy', :loan_question_set
end
