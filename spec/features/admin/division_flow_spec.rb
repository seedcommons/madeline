require 'rails_helper'

feature 'division flow' do

  let(:division) { create(:division) }
  let(:user) { create(:person, :with_admin_access, :with_password, division: division).user }

  before do
    login_as(user, scope: :user)
  end

  include_examples :flow do
    let(:model_to_test) { division }
  end

  scenario 'can change change to division and back', js: true do
    visit(root_path)
    expect(find('[data-expands="division-dropdown"]')).to have_content 'Select Division'

    # Change to specific division, and ensure the page reloads properly
    find('[data-expands="division-dropdown"]').click
    find('.select_division_form').select(division.name)
    expect(find('[data-expands="division-dropdown"]')).to have_content 'Change Division'
    expect(find('.without-logo')).to have_content division.name

    # Change back to all divisions, and ensure it reloads properly
    find('[data-expands="division-dropdown"]').click
    find('.select_division_form').select('All Divisions')
    expect(find('.madeline')).to have_content 'Madeline'
    expect(find('[data-expands="division-dropdown"]')).to have_content 'Select Division'
  end
end
