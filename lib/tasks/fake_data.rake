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
        :with_timeline,
        :with_transaction,
        :with_log_media,
        :with_loan_media,
        :with_coop_media)
      FactoryGirl.create(:loan,
        :with_translations,
        :with_foreign_translations,
        :with_steps_only_timeline,
        :with_log_media,
        :with_transaction,
        :with_loan_media,
        :with_coop_media)
      FactoryGirl.create_list(:loan, 13, :with_transaction)
      puts "Generated fake data"
    end
  end
end
