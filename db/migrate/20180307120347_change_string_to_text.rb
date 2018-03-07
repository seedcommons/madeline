class ChangeStringToText < ActiveRecord::Migration[5.1]
  def change
    LoanQuestion.where(data_type: 'string').update_all(data_type: 'text')
  end
end
