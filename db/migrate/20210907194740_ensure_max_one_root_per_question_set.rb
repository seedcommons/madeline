class EnsureMaxOneRootPerQuestionSet < ActiveRecord::Migration[6.1]
  def change
    add_index :questions, "question_set_id, (parent_id IS NULL)",
              where: "parent_id IS NULL",
              unique: true,
              comment: "Ensures max one root per question set"
  end
end
