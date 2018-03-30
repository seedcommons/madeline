if Rails.env.development?
  namespace :dev do
    desc "Delete all data from database, seed, and generate fake_data"
    task db_reset: :environment do
      Rake::Task['dev:db_clean'].invoke
      Rake::Task['db:seed'].invoke
      Rake::Task['dev:fake_data'].invoke
    end

    desc "Delete all data from database without needing to drop and recreate"
    task db_clean: :environment do
      # ActiveRecord::Base.connection.execute('drop schema public cascade; create schema public')
      DatabaseCleaner.clean_with(:truncation)
    end

    desc "Generate UI testing data"
    task fake_data: :environment do
      division = FactoryBot.create(:division)

      # Create admin user
      # user = FactoryBot.create(:user, :admin,
      #   email: "admin@example.com",
      #   password: "xxxxxxxx",
      #   password_confirmation: "xxxxxxxx"
      # )
      # user.add_role :admin, Division.root
      # puts "Created default admin user"
      # puts "Login: #{user.email}"
      # puts "Password: xxxxxxxx"

      # Create some data
      FactoryBot.create_list(:loan, 30,
        :with_translations,
        :with_foreign_translations,
        :with_timeline,
        :with_log_media,
        :with_loan_media,
        :with_coop_media,
        division: division)
      FactoryBot.create(:loan,
        :with_translations,
        :with_foreign_translations,
        :with_steps_only_timeline,
        :with_log_media,
        :with_loan_media,
        :with_coop_media,
        division: division)
      FactoryBot.create_list(:loan, 13, division: division)
      puts "Generated fake data"
    end
  end
end
