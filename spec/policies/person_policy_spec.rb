require 'rails_helper'

describe PersonPolicy do
  it_should_behave_like 'base_policy', :person
end
