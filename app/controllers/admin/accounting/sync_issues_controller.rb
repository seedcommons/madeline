module Admin
  module Accounting
    class SyncIssuesController < Admin::AdminController
      def index
        authorize :'accounting/sync_issue', :index?
        if params[:loan_id]
          @loan_id = params[:loan_id]
          @issues = ::Accounting::SyncIssue.for_loan_or_global(@loan_id)

          # Group by transactions so that we can do row spans.
          @issues = @issues.group_by(&:txn_id)
        else
          @issues = ::Accounting::SyncIssue.order(:project_id).group_by(&:project_id)
          render :index_by_loan
        end
      end

      def show
        @issue = ::Accounting::SyncIssue.find(params[:id])
        authorize @issue
      end
    end
  end
end
