namespace :madeline do
  desc 'update option sets'
  task update_option_sets: :environment do
    OptionSetCreator.new.update_all
  end
end
