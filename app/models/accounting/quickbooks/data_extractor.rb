module Accounting
  module Quickbooks
    class DataExtractor
      def initialize(obj)
        case obj.qb_object_type
        when "JournalEntry"
          Accounting::Quickbooks::TransactionExtractor.new(obj)
        end
      end
    end
  end
end
