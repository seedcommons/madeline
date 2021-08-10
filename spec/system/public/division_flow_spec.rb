require 'rails_helper'

feature 'public division flow' do
  let!(:parent_division) { create(:division, name: "parent") }
  let!(:sub_div_a) { create(:division, parent: parent_division, name: "sub div a") }
  let!(:sub_div_b) { create(:division, parent: parent_division, name: "sub div b") }
  let!(:loan_active_a) { create(:loan, :active, :public, name: "active a", division: sub_div_a,) }
  let!(:loan_completed_a) { create(:loan, :completed, :public, name: "completed a", division: sub_div_a) }
  let!(:loan_hidden_a) { create(:loan, :active, name: "hidden a", division: sub_div_a, public_level_value: :hidden) }
  let!(:loan_active_b) { create(:loan, :active, :public, name: "active b", division: sub_div_b) }
  let!(:loan_completed_b) { create(:loan, :completed, :public, name: "completed b", division: sub_div_b) }
  let!(:loan_hidden_b) { create(:loan, :active, name: "hidden b", division: sub_div_b, public_level_value: :hidden) }

  it 'displays division information' do
    visit public_division_path(short_name: parent_division.short_name)
    expect(page).to have_content(parent_division.name)
  end

  it 'filters loans correctly' do
    visit public_division_path(short_name: parent_division.short_name)
    expect(page).to have_content(parent_division.name)
    # defaults to showing "active"
    expect(page).to have_content(loan_active_a.name)
    expect(page).to have_content(loan_active_b.name)
    expect(page).not_to have_content(loan_completed_a.name)
    expect(page).not_to have_content(loan_completed_b.name)
    expect(page).not_to have_content(loan_hidden_a.name)
    expect(page).not_to have_content(loan_hidden_b.name)

    # filter to completed
    click_on("Completed")
    expect(page).not_to have_content(loan_active_a.name)
    expect(page).not_to have_content(loan_active_b.name)
    expect(page).to have_content(loan_completed_a.name)
    expect(page).to have_content(loan_completed_b.name)
    expect(page).not_to have_content(loan_hidden_a.name)
    expect(page).not_to have_content(loan_hidden_b.name)

    # filter to all
    click_on("All")
    expect(page).to have_content(loan_active_a.name)
    expect(page).to have_content(loan_active_b.name)
    expect(page).to have_content(loan_completed_a.name)
    expect(page).to have_content(loan_completed_b.name)
    expect(page).not_to have_content(loan_hidden_a.name)
    expect(page).not_to have_content(loan_hidden_b.name)

    # filter by division
    select sub_div_a.name, from: "division"
    # workaround for problems with relative and absolute urls not working in capybara
    visit public_division_path(short_name: sub_div_a.short_name, status: "all")
    expect(page).to have_content(loan_active_a.name)
    expect(page).not_to have_content(loan_active_b.name)
    expect(page).to have_content(loan_completed_a.name)
    expect(page).not_to have_content(loan_completed_b.name)
    expect(page).not_to have_content(loan_hidden_a.name)
    expect(page).not_to have_content(loan_hidden_b.name)
  end
end
