require 'rails_helper'

feature 'division flow' do

  let(:division) { create(:division, name: 'Cream') }
  let!(:jay_division) { create(:division, name: 'Jayita', parent: division) }
  let(:person) { create(:person, :with_admin_access, :with_password) }
  let(:user) { person.user }

  before do
    login_as(user, scope: :user)
  end

  include_examples :flow do
    subject { division }
  end

  scenario 'division name does not show in parent division dropdown' do
    visit admin_division_path(division)
    find('.edit-action').click
    expect(page).to have_select('division_parent_id', visible: true, options: %w(- Jayita))
  end
end
