module Accounting
  class InterestCalculator
    def recalculate_line_item(loan)
      prev_txn = nil

      loan.transactions.standard_order.each_with_index do |txn, i|
        prev_txn = nil if i == 0
        current_txn = txn

        txn if current_txn != prev_txn

        txn.calculate_balances(prev_tx: prev_txn)

        prev_txn = current_txn
      end
    end
  end
end
