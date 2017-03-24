class LoansController < ApplicationController
  include WordpressEmbeddable
  # GET /loans
  # GET /loans.json
  def index
    params[:division] = get_division_from_url
    @loans = Loan.filter_by_params(params).visible.
      includes(:organization, division: :parent).
      page(params[:pg]).per(20).
      order('signing_date DESC')
    @countries = Country.order(:iso_code).pluck(:iso_code)

    # Set last loan list URL for 'Back to Loan List' link
    session[:loans_path] = request.fullpath

    respond_to do |format|
      format.html
      format.json { render json: @loans }
    end
  end

  # GET /loans/1
  # GET /loans/1.json
  def show
    @loan = Loan.status('all').find(params[:id])
    @pictures = @loan.featured_pictures(5) # for slideshow
    @other_loans = @loan.organization.loans.status('all').order("SigningDate DESC") if @loan.organization
    @repayments = @loan.repayments.order('DateDue')

    respond_to do |format|
      format.html
      format.json { render :json => @loan }
    end
  end

  # GET /loans/1/gallery
  def gallery
    @loan = Loan.status('all').find(params[:id])
    @coop_media = @loan.coop_media(100, true).in_groups_of(4, false)
    @loan_media = (@loan.loan_media(100, true) + @loan.log_media(100, true)).in_groups_of(4, false)

    respond_to do |format|
      format.html
    end
  end
end
