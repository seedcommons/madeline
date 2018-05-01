class FixQuestionTranslations < ActiveRecord::Migration[5.1]
  def up
    Translation.where(translatable_type: "LoanQuestion").update_all(translatable_type: "Question")
  end

  def down
    Translation.where(translatable_type: "Question").update_all(translatable_type: "LoanQuestion")
  end
end
