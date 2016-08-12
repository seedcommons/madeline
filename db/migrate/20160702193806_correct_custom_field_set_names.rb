class CorrectCustomFieldSetNames < ActiveRecord::Migration
  def up
    if defined? CustomValueSet
      puts CustomValueSet.where(linkable_attribute: 'criteria').update_all(linkable_attribute: 'loan_criteria')
      puts CustomValueSet.where(linkable_attribute: 'post_analysis').update_all(linkable_attribute: 'loan_post_analysis')
    end
  end
end
