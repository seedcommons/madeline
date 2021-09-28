class AddLoanPrefixToResponseSetKinds < ActiveRecord::Migration[6.1]
  def up
    execute("UPDATE response_sets SET kind = 'loan_' || kind")
  end

  def down
    execute("UPDATE response_sets SET kind = substring(kind from 6)")
  end
end
