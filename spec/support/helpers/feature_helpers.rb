module FeatureHelpers
  include Warden::Test::Helpers

  def sign_in(user = nil)
    user ||= FactoryGirl.create(:user)
    login_as user, scope: :user
    user
  end
end
