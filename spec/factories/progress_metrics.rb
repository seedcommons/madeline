FactoryGirl.define do
  factory :progress_metric do
    english_display_continuous 'advancing as expected'
    english_display_with_events 'on time'
    level 1
    spanish_display_continuous 'avanzando como se esperaba'
    spanish_display_with_events 'a tiempoa'
  end
end
