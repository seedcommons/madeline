class Public::LoansController < Public::PublicController
  include WordpressEmbeddable
  after_action :verify_authorized

  def index
    params[:division] = get_division_from_url
    @params = { status: params[:status], pg: params[:pg], country: params[:country] }
    @loans = policy_scope(Loan.filter_by_params(params).visible.
          includes(:organization, division: :parent).
          page(params[:pg]).per(20).
          order('signing_date DESC'))
    authorize @loans
    @countries = Country.order(:iso_code).pluck(:iso_code)


    # Set last loan list URL for 'Back to Loan List' link
    session[:loans_path] = request.fullpath
  end

  def show
    @loan = Loan.find(params[:id])
    @pictures = @loan.featured_pictures(5) # for slideshow
    @other_loans = policy_scope(Loan.related_loans(@loan))
    
    authorize @loan
  end

  def gallery
    @loan = Loan.find(params[:id])
    @coop_media = @loan.coop_media(100, true).in_groups_of(4, false)
    @loan_media = (@loan.loan_media(100, true) + @loan.log_media(100, true)).in_groups_of(4, false)
    authorize @loan
  end
end
