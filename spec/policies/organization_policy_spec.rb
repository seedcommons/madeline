require 'rails_helper'

describe OrganizationPolicy do
  it_should_behave_like 'base_policy', :organization
  it_should_behave_like 'division_owned_scope', :organization
end
