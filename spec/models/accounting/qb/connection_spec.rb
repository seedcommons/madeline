require 'rails_helper'

describe Accounting::QB::Connection, type: :model do
  # need to know that connected? returns true if  it's not expired,
  # no invalid grant

  # if time, stub OAuth2::AccessToken refresh & test that. 
end
