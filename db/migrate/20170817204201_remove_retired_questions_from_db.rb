class LoanQuestion < ActiveRecord::Base
  has_many :loan_question_requirements, dependent: :destroy
  has_many :translations, as: :translatable, dependent: :destroy
end

class RemoveRetiredQuestionsFromDb < ActiveRecord::Migration
  def up
    # These are not supposed to show anywhere for now and they're gumming up the code, so we'll just
    # dump them to a file and remove them
    LoanQuestion.where(status: 'retired').destroy_all
  end
end
