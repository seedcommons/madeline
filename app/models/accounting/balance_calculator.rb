module Accounting
  # Calculates the interest/capital deltas and running balances
  # of a given transaction and all the ones after it
  class TransactionCalculator
    attr_accessor :subject

    def initialize(subject)
      self.subject = subject
    end

    def recalculate!
      previous = first_before
      subject_and_after.each do |current|
        recalculate_transaction(current, previous)
        current.save!
        previous = current
      end
    end

    private

    # Gets the first transaction before the subject
    def first_before

    end

    # Gets all transcations subsequent (and including) the subject
    def subject_and_after

    end

    # Recalculates various attribs of the given transaction
    # Depends on the previous transaction for running balances
    def recalculate_transaction(transaction, previous_transaction)

    end
  end
end
