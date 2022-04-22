class ReAddUniqIndexOnAnswersForResponseSetAndQuestions < ActiveRecord::Migration[6.1]
  def change
    add_index :answers, %i[response_set_id question_id], unique: true
  end
end
