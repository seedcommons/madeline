FactoryGirl.define do
  factory :project_log do
    additional_notes { Faker::Lorem.sentences(3) }
    date { Faker::Date.between(Date.civil(2004, 01, 01), Date.today)}
    detailed_explanation { Faker::Lorem.paragraphs(3) }
    explanation { Faker::Lorem.sentences(3) }
    notas_privadas { Faker::Lorem.paragraph }
    paso_id { create(:project_event).id }
    progress_metric { create(:progress_metric).id }
    project_id { create(:basic_project).id }
    project_table 'BasicProjects'
  end
end
