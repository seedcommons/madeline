class QuickbooksPolicy < ApplicationPolicy
  def authenticate?
    true
  end

  def oauth_callback?
    true
  end

  def disconnect?
    true
  end
end
