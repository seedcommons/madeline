# frozen_string_literal: true

module Admin
  class LoansController < Admin::ProjectsController
    include QuestionnaireRenderable
    include LoansHelper

    TABS = %w(details questions timeline logs transactions calendar).freeze

    def index
      authorize(Loan)

      @loans_grid = initialize_grid(
        policy_scope(Loan),
        include: %i[division organization currency primary_agent secondary_agent],
        conditions: division_index_filter,
        order: "projects.signing_date",
        order_direction: "desc",
        per_page: 50,
        name: "loans",
        enable_export_to_csv: true
      )

      @csv_mode = true
      @enable_export_to_csv = true

      export_grid_if_requested("loans": "loans_grid_definition") do
        # This block only executes if CSV is not being returned
        @csv_mode = false
      end
    end

    def show
      @loan = Loan.find(params[:id])
      authorize(@loan)
      @relocate_alerts = true # Show alerts inside tab
      @tab = params[:tab]

      case @tab
      when "questions"
        prep_questionnaire
      when "timeline"
        prep_timeline(@loan)
      when "logs"
        prep_logs(@loan)
      when "transactions"
        # requires additional level of validation beyond approrpiate loan access
        @sample_transaction = ::Accounting::Transaction.new(project: @loan, managed: true)
        authorize @sample_transaction, :index?
        prep_transactions
      when "calendar"
        @locale = I18n.locale
        @calendar_events_url = "/admin/calendar_events?project_id=#{@loan.id}"
      else
        # Ensure @tab defaults to details if it's set to something unrecognized.
        @tab = "details"
        prep_form_vars
      end

      render(partial: "admin/loans/details") if request.xhr?
    end

    def new
      @loan = Loan.new(division: selected_division_or_root,
                       currency: selected_division_or_root.default_currency)
      @loan.organization_id = params[:organization_id] if params[:organization_id]
      authorize(@loan)
      prep_form_vars
    end

    def update
      @loan = Loan.find(params[:id])
      authorize(@loan)
      @loan.assign_attributes(loan_params)

      if @loan.save
        redirect_to(admin_loan_path(@loan), notice: I18n.t(:notice_updated))
      else
        prep_form_vars
        render(:show)
      end
    end

    def create
      @loan = Loan.new(loan_params)
      authorize(@loan)

      org_id = params[:loan][:organization_id]

      if @loan.save
        if params[:from_org] == "yes"
          redirect_to(admin_organization_path(org_id), notice: I18n.t(:notice_created))
        else
          redirect_to(admin_loan_path(@loan), notice: I18n.t(:notice_created))
        end
      else
        prep_form_vars
        render(:new)
      end
    end

    def destroy
      @loan = Loan.find(params[:id])
      authorize(@loan)

      if @loan.destroy
        redirect_to(admin_loans_path, notice: I18n.t(:notice_deleted))
      else
        prep_form_vars
        render(:show)
      end
    end

    def duplicate
      @loan = Loan.find(params[:id])
      authorize(@loan, :new?)

      new_loan = ProjectDuplicator.new(@loan).duplicate

      redirect_to(admin_loan_path(new_loan), notice: I18n.t("loan.duplicated_message"))
    end

    def print
      @loan = Loan.find(params[:id])
      authorize(@loan, :show?)
      @print_view = true
      @mode = params[:mode]
      @images = @loan.media.where(kind_value: "image")
      # Group every 8 images
      @image_list = @images.where.not(featured: true).each_slice(8).to_a
      prep_questionnaire(json: false)
      prep_attached_links if @mode != "details-only"
    end

    def statement
      @loan = Loan.find(params[:id])
      @start_date = Time.zone.now.last_year.beginning_of_year
      @end_date = Time.zone.now.last_year.end_of_year
      @transactions = @loan.transactions.in_date_range(@start_date, @end_date)
      authorize(@loan, :show?)
      # get applicable transactions
      render partial: "admin/loans/statement", layout: false
    end

    private

    def loan_params
      params.require(:loan).permit(*(
        %i[
          division_id organization_id loan_type_value status_value name final_repayment_formula
          amount currency_id source_of_capital primary_agent_id secondary_agent_id projected_first_payment_date
          length_months rate signing_date actual_first_payment_date projected_end_date
          project_type_value actual_end_date public_level_value txn_handling_mode
        ] + translation_params(:summary, :details)
      ))
    end

    def prep_form_vars
      @tab ||= "details"
      @org_choices = Organization.in_ancestor_or_descendant_division(@loan.division).by_name
      @agent_choices = Person.in_ancestor_or_descendant_division(@loan.division).by_name
      @currency_choices = Currency.all.order(:name)
      @source_of_capital_choices = source_of_capital_choices
      @txn_mode_choices = txn_mode_options
      prep_criteria
    end

    def prep_attached_links
      prep_criteria
      @attached_links = @loan_criteria&.embedded_urls
      return if @attached_links.blank?

      open_link_text = view_context.link_to(I18n.t("loan.open_links", count: @attached_links.length),
                                            "#", data: {action: "open-links", links: @attached_links})
      notice_text = "".html_safe
      notice_text << I18n.t("loan.num_of_links", count: @attached_links.length) << " " << open_link_text
      notice_text << " " << I18n.t("loan.popup_blocker") if @attached_links.length > 1
      flash.now[:alert] = notice_text
    end

    def prep_transactions
      @errors = ::Accounting::SyncIssue.for_loan_or_global(@loan).error
      @warnings = ::Accounting::SyncIssue.for_loan_or_global(@loan).warning
      @transactions = ::Accounting::Transaction.where(project: @loan).extracted
      @transactions.includes(:account, :project, :currency, :line_items).standard_order
      @enable_export_to_csv = true
      @transactions_grid = initialize_grid(
        @transactions.standard_order,
        enable_export_to_csv: @enable_export_to_csv,
        per_page: 200,
        name: "transactions"
      )
      export_grid_if_requested('transactions': "admin/accounting/transactions/transactions_grid_definition")
      show_reasons_if_read_only
    end

    def prep_criteria
      @loan_criteria = ResponseSet.find_with_loan_and_kind(@loan, "loan_criteria")
    end

    def show_reasons_if_read_only
      return if (reasons = policy(@sample_transaction).read_only_reasons).empty?

      args = {}
      args[:selected_division] = @loan.division.name
      args[:qb_division] = @loan.qb_division&.name
      args[:qb_division_settings_link] =
        view_context.link_to(t("common.settings"), admin_division_path(@loan.division))
      args[:accounting_settings_link] =
        view_context.link_to(t("common.settings"), admin_accounting_settings_path)
      reasons = reasons.map { |r| t("quickbooks.read_only_reasons.#{r}_html", args) }.join("; ")
      flash.now[:alert] = t("quickbooks.read_only_html", reasons: reasons)
    end
  end
end
