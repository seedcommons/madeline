class ChangeCriteriaBackToLoanCriteria < ActiveRecord::Migration
  def up
    puts CustomValueSet.where(linkable_attribute: 'criteria').update_all(linkable_attribute: 'loan_criteria')
    puts CustomValueSet.where(linkable_attribute: 'post_analysis').update_all(linkable_attribute: 'loan_post_analysis')
  end
end
