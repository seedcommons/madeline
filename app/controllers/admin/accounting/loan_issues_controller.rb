module Admin
  module Accounting
    class LoanIssuesController < Admin::AdminController
      def index
        authorize :'accounting/loan_issue', :index?
        if params[:loan_id]
          @loan_id = params[:loan_id]
          txn_ids = LoanIssue.where(project_id: @loan_id).map(&:accounting_transaction_id)
          @issues = LoanIssue.where(accounting_transaction_id: txn_ids).group_by(&:txn_id)
        else
          @issues = LoanIssue.all.sort_by(&:project_id).group_by(&:project_id)
          render :index_by_loan
        end
      end

      def show
        @issue = LoanIssue.find(params[:id])
        authorize @issue
      end
    end
  end
end
