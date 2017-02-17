require 'rails_helper'

feature 'login' do
  let(:user) { create_member(create(:division)) }

  scenario 'should work', js: true do
    visit('/users/sign_in')
    fill_in('Email', with: user.email)
    fill_in('Password', with: user.password)
    click_on('Login')
    expect(page).to have_content('Signed in successfully')
  end
end
