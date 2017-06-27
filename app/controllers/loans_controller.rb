class LoansController < ApplicationController
  include WordpressEmbeddable

  def index
    params[:division] = get_division_from_url
    @loans = Loan.filter_by_params(params).visible.
      includes(:organization, division: :parent).
      page(params[:pg]).
      per(20).
      order('signing_date DESC')
    @countries = Country.order(:iso_code).pluck(:iso_code)

    # Set last loan list URL for 'Back to Loan List' link
    session[:loans_path] = request.fullpath
  end

  def show
    @loan = Loan.status('all').find(params[:id])
    @pictures = @loan.featured_pictures(5) # for slideshow
    @other_loans = @loan.cooperative.loans.status('all').order("SigningDate DESC") if @loan.cooperative
    @repayments = @loan.repayments.order('DateDue')
  end

  def gallery
    @loan = Loan.status('all').find(params[:id])
    @coop_media = @loan.coop_media(100, true).in_groups_of(4, false)
    @loan_media = (@loan.loan_media(100, true) + @loan.log_media(100, true)).in_groups_of(4, false)
  end
end
