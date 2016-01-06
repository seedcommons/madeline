FactoryGirl.define do
  factory :project_log do
    # project_table 'Loan'
    # project_id { create(:loan).id }
    project_step #{ create(:project_step).id }
    person
    date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today)}
    progress_metric_option_id { ProjectLog::PROGRESS_METRIC_OPTIONS.values.sample }

    # need to make sure parent saved before assigning these
    # leave out of factory until a better solution is found
    # note, these fields can still be regression tested via:
    #   it_should_behave_like 'translatable', ['summary', 'details']
    #
    # summary { Faker::Lorem.sentences(3) }
    # details { Faker::Lorem.paragraphs(3) }
    # additional_notes { Faker::Lorem.sentences(3) }
    # private_notes { Faker::Lorem.paragraph }

  end
end
