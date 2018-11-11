module Accounting
  module Quickbooks
    class DataExtractor
      def initialize(object)
        @object = object

        case @object.qb_object_type
        when "JournalEntry", "Deposit", "Bill"
          @extractor = Accounting::Quickbooks::JournalEntryExtractor.new(@object)
        when "Purchase"
          @extractor = Accounting::Quickbooks::PurchaseExtractor.new(@object)
        else
          raise "DataExtractor instantiated with invalid object"
        end
      end

      def extract!
        @extractor.extract!
      end
    end
  end
end
