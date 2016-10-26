if Rails.env.development?
  namespace :dev do
    desc "Generate UI testing data"
    task fake_data: :environment do
      # Create admin user
      user = FactoryGirl.create(:user, :admin,
        email: "admin@example.com",
        password: "xxxxxxxx",
        password_confirmation: "xxxxxxxx"
      )
      user.add_role :admin, Division.root
      puts "Created default admin user"
      puts "Login: #{user.email}"
      puts "Password: xxxxxxxx"

      # Create some data
      FactoryGirl.create(:loan,
        :with_translations,
        :with_foreign_translations,
        :with_log_media,
        :with_loan_media,
        :with_coop_media,
        :with_timeline)
      FactoryGirl.create(:loan,
        :with_translations,
        :with_foreign_translations,
        :with_log_media,
        :with_loan_media,
        :with_coop_media,
        :with_steps_only_timeline)
      FactoryGirl.create_list(:loan, 13)
      puts "Generated fake data"
    end
  end
end
