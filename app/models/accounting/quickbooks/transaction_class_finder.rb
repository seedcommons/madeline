module Accounting
  module Quickbooks
    class FindError < StandardError; end

    # This class is responsible for batching up Quickbooks API calls into separate types.
    # The API does support batch requests for queries, but quickbooks-ruby does not.
    class TransactionClassFinder
      attr_reader :qb_connection
      attr_accessor :division

      def initialize(division)
        @division = division
        @qb_connection = division.qb_connection
      end

      def find_by_name(name)
        service = ::Quickbooks::Service::Class.new(qb_connection.auth_details)
        result = service.query("Select Id, Name from Class Where Name = '#{name}'")
        if result.count == 1
          division.qb_parent_class_id = result.entries[0].id
          division.save
        else
          nil # TODO: report appropriate errors when UI for searching added
        end
      end
    end
  end
end
