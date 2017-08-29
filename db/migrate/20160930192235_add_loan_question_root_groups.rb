class AddLoanQuestionRootGroups < ActiveRecord::Migration
  def up
    # Guard against future model changes.
    if defined?(QuestionSet) && QuestionSet.respond_to?(:create_root_groups!)
      p "HERE"
      QuestionSet.create_root_groups!
    end
  end
end
