class RemoveResponseSetDuplicates < ActiveRecord::Migration[6.1]
  def up
    duplicate_ids = ResponseSet.where.not(kind: QuestionSet::KINDS).pluck(:id)
    if duplicate_ids.any?
      if Rails.env.production?
        raise "Not deleting duplicate response sets in production. Please remove manually"
      else
        say_with_time "Removing duplicate ResponseSets (#{duplicate_ids.join(', ')})" do
          ResponseSet.where(id: duplicate_ids).delete_all
        end
      end
    end
  end
end
