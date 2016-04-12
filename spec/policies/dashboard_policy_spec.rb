require 'rails_helper'

describe DashboardPolicy do
  subject { described_class.new(user, nil) }

  context 'with logged in user' do
    let(:user) { create(:user) }

    permit_actions [:index]
  end

  context 'with logged out user' do
    let(:user) { nil }

    forbid_actions [:index]
  end
end
