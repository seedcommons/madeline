namespace :generate do
  desc 'Generates UI testing data for loans'
  task loan_data: :environment do
    FactoryGirl.create_list(:loan, 25, :with_translations, :with_project_steps)
  end
end
