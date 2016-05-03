require 'rails_helper'

describe LoanPolicy do
  it_should_behave_like 'base_policy', :loan
  it_should_behave_like 'division_owned_scope', :loan
end
