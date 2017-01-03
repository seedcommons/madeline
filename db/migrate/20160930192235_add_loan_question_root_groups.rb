class AddLoanQuestionRootGroups < ActiveRecord::Migration
  def up
    # Guard against future model changes.
    if defined?(LoanQuestionSet) && LoanQuestionSet.respond_to?(:create_root_groups!)
      p "HERE"
      LoanQuestionSet.create_root_groups!
    end
  end
end
