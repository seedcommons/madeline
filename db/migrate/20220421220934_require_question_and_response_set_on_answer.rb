class RequireQuestionAndResponseSetOnAnswer < ActiveRecord::Migration[6.1]
  def change
    Answer.where(response_set_id: nil).delete_all
    Answer.where(question_id: nil).delete_all
    remove_reference :answers, :response_set, index: true, foreign_key: true
    add_reference :answers, :response_set, index: true, foreign_key: true, null: false
    remove_reference :answers, :question, index: true, foreign_key: true
    add_reference :answers, :question, index: true, foreign_key: true, null: false
  end
end
