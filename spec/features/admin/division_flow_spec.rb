require 'rails_helper'

feature 'division flow' do
  let!(:division) { create(:division, name: 'Cream', short_name: 'cream') }
  let(:person) { create(:person, :with_admin_access, :with_password) }
  let(:user) { person.user }

  before do
    allow(SecureRandom).to receive(:uuid) { 'iamauuid2018' }
    login_as(user, scope: :user)
  end

  include_examples :flow do
    subject { division }
  end

  scenario "division and parent division can't be the same" do
    visit admin_division_path(division)
    find('.edit-action').click
    select 'Cream', from: 'division_parent_id'
    click_on 'Update Division'
    expect(page).to have_content('Division and Parent Division cannot be the same')
  end

  scenario 'divisions can not have duplicate short names' do
    visit admin_divisions_path
    click_on 'New Division'
    fill_in 'division_name', with: 'Jay'
    fill_in 'Short Name', with: 'cream'
    click_on 'Create Division'
    expect(page).to have_content('jay-iamauuid2018')

    # on edit
    visit admin_division_path(Division.last)
    find('.edit-action').click
    fill_in 'Short Name', with: 'cream'
    click_on 'Update Division'
    expect(page).to have_content('jay')
  end

  context 'editing qb department' do
    let!(:departments) {
      %w(Dep1 Dep2 Dep3).map do |name|
        create(:department, name: name)
      end
    }
    scenario 'set department' do
      visit admin_division_path(division)
      find('.edit-action').click
      select 'Dep2', from: 'division_qb_department_id'
      click_on 'Update Division'
      expect(page.find('.division_qb_department_id .view-element')).to have_content('Dep2')
    end
  end
end
