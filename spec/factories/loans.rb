FactoryGirl.define do
  factory :loan do
    amount { rand(5000..50000)}
    cooperative
    cooperative_members { rand(1..200) }
    description { Faker::Lorem.sentences(3) }
    description_english { Faker::Lorem.sentences(3) }
    fecha_de_finalizacion { Faker::Date.between(first_payment_date, Date.today) }
    first_interest_payment { Faker::Date.between(signing_date, Date.today) }
    first_payment_date { Faker::Date.between(signing_date, Date.today) }
    length {rand(1..36) }
    # Other statuses: "Prestamo Congelado", "Prestamo Liquidado", "Prestamo Prospectivo", "Prestamo Refinanciado", "Relacion", "Relacion Activo"
    nivel { ["Prestamo Activo", "Prestamo Completo"].sample }
    short_description { description.split('.').first }
    short_description_english { description_english.split('.').first }
    signing_date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    source_division { create(:division_with_country).id }

    trait :active do
      nivel 'Prestamo Activo'
    end

    trait :completed do
      nivel 'Prestamo Completo'
    end

    trait :with_translations do
      after(:create) do |loan|
        create(:translation, remote_table: 'Loans', remote_column_name: 'Description', remote_id: loan.id)
        create(:translation, remote_table: 'Loans', remote_column_name: 'ShortDescription', remote_id: loan.id)
      end
    end

    trait :with_foreign_translations do
      after(:create) do |loan|
        language_id = create(:language, code: 'ES', name: 'Spanish').id
        create(:translation, remote_table: 'Loans', remote_column_name: 'Description', remote_id: loan.id, language: language_id)
        create(:translation, remote_table: 'Loans', remote_column_name: 'ShortDescription', remote_id: loan.id, language: language_id)
      end
    end

    trait :with_loan_media do
      after(:create) do |loan|
        create_list(:media, 5, context_table: 'Loans', context_id: loan.id)
      end
    end

    trait :with_coop_media do
      after(:create) do |loan|
        create_list(:media, 5, context_table: 'Cooperatives', context_id: loan.cooperative.id)
      end
    end

    trait :with_log_media do
      with_project_events
      after(:create) do |loan|
        loan.logs.each do |log|
          create_list(:media, 2, context_table: 'ProjectLogs', context_id: log.id)
        end
      end
    end

    trait :with_one_project_event do
      after(:create) do |loan|
        create(:project_event, :with_logs, project_table: 'Loans', project_id: loan.id)
      end
    end

    trait :with_project_events do
      after(:create) do |loan|
        create_list(
          :project_event,
          num_events = 3,
          :with_logs,
          :for_loan,
          loan_id: loan.id
        )
        create(:project_event, :with_logs, :completed, :for_loan, loan_id: loan.id)
      end
    end

    trait :with_repayments do
      after(:create) do |loan|
        paid = create_list(:repayment, num_repayments = 2, :paid, loan_id: loan.id)
        unpaid = create_list(:repayment, num_repayments = 3, loan_id: loan.id)
      end
    end
  end
end
