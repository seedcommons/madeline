require 'rails_helper'

# wice grid tables are being used in a lot of places so we'll pick one for the
# spec since it's all being powered by one partial: admin/common/grid

feature 'wice grid' do

  let(:division) { create(:division) }
  let(:user) { create_member(division) }

  before do
    login_as(user, scope: :user)
  end

  context do
    let!(:basic_project) { create(:basic_project, division: division) }

    scenario 'record(s) show when there is one' do
      visit admin_basic_projects_path
      expect(page).to have_css('.wice-grid-container')
      expect(page).not_to have_css('.no-records-match')
    end
  end

  context do
    let!(:basic_project) { nil }

    scenario 'record(s) show when there is one' do
      visit admin_basic_projects_path
      expect(page).not_to have_css('.wice-grid-container')
      expect(page).to have_css('.no-records-match')
    end
  end
end
