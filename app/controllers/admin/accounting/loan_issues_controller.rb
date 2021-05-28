module Admin
  module Accounting
    class LoanIssuesController < Admin::AdminController
      def index
        authorize :'accounting/loan_issue', :index?
        if params[:loan_id]
          @loan_id = params[:loan_id]
          @issues = ::Accounting::LoanIssue.where(project_id: @loan_id)

          # We include issues with no project ID for all projects.
          @issues = @issues.or(::Accounting::LoanIssue.where(project_id: nil))

          # Group by transactions so that we can do row spans.
          @issues = @issues.group_by(&:txn_id)
        else
          @issues = ::Accounting::LoanIssue.order(:project_id).group_by(&:project_id)
          render :index_by_loan
        end
      end

      def show
        @issue = ::Accounting::LoanIssue.find(params[:id])
        authorize @issue
      end
    end
  end
end
