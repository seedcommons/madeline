class Accounting::QBPolicy < ApplicationPolicy
  def authenticate?
    division_admin(division: Division.root)
  end

  def oauth_callback?
    division_admin(division: Division.root)
  end

  def disconnect?
    division_admin(division: Division.root)
  end

  def reset_data?
    division_admin(division: Division.root)
  end
end
