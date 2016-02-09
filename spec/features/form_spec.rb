require 'rails_helper'

feature 'forms' do
  describe 'show/edit' do
    it 'shows values and not input fields by default'
    it 'shows input fields and not values after pressing edit'
    it 'cancel button returns to show mode'
  end

  it 'shows errors when invalid'
  it 'cancel works when errors'
end
