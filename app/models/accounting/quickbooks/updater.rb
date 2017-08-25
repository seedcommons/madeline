module Accounting
  module Quickbooks
    class FullSyncRequiredError < StandardError; end
    class NotConnectedError < StandardError; end

    # Reponsible for grabbing only the updates that have happened in quickbooks
    # since the last time this class was run. If no quickbooks data exists in the sytem
    # yet, FullFetcher will need to be run first.
    class Updater
      attr_reader :qb_connection

      def initialize(qb_connection = Division.root.qb_connection)
        @qb_connection = qb_connection
      end

      def update
        raise NotConnectedError unless qb_connection

        update_started_at = Time.zone.now

        updated_models = changes.flat_map do |type, qb_objects|
          qb_objects.map do |qb_object|
            if should_be_deleted?(qb_object)
              delete_qb_object(transaction_type: type, qb_object: qb_object)
            else
              find_or_create(transaction_type: type, qb_object: qb_object)
            end
          end
        end

        qb_connection.update_attribute(:last_updated_at, update_started_at)

        updated_models
      end

      private

      def changes
        raise FullSyncRequiredError, "Last update was more than 30 days ago, please do a full sync" unless last_updated_at && last_updated_at > max_updated_at

        service.since(types, last_updated_at).all_types
      end

      def find_or_create(transaction_type:, qb_object:)
        model = ar_model_for(transaction_type)

        model.create_or_update_from_qb_object transaction_type: transaction_type, qb_object: qb_object
      end

      def types
        Accounting::Transaction::QB_TRANSACTION_TYPES + [Accounting::Account::QB_TRANSACTION_TYPE]
      end

      def ar_model_for(transaction_type)
        return Accounting::Account if Accounting::Account::QB_TRANSACTION_TYPE == transaction_type
        Accounting::Transaction
      end

      def delete_qb_object(transaction_type:, qb_object:)
        model = ar_model_for(transaction_type)
        model.destroy_all(qb_id: qb_object.id)
      end

      def should_be_deleted?(qb_object)
        qb_object.try(:status) == 'Deleted'
      end

      def service
        ::Quickbooks::Service::ChangeDataCapture.new(qb_connection.auth_details)
      end

      def max_updated_at
        30.days.ago - 1.minute
      end

      def last_updated_at
        qb_connection.last_updated_at
      end
    end
  end
end
