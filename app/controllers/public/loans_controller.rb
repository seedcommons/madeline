class Public::LoansController < Public::PublicController
  include WordpressEmbeddable


  def index
    division = params[:division] || division_for_site(params[:site])
    redirect_to controller: "divisions", action: "show", short_name: division
  end

  def division_for_site(site)
    case site.downcase
      when "us"
        "seed-commons"
      when "nicaragua"
        "la-base-nicaragua"
      when "argentina"
        "la-base-argentina"
      else
        "seed-commons"
      end
  end

  def show
    @loan = Loan.find(params[:id])
    authorize @loan

    @pictures = @loan.featured_pictures(limit: 5) # for slideshow
    @other_loans = policy_scope(Loan.related_loans(@loan).active_or_completed.order('signing_date desc'))
  end

  def gallery
    @loan = Loan.find(params[:id])
    authorize @loan

    @coop_media = @loan.coop_media(limit: 100, images_only: true).in_groups_of(4, false)
    @loan_media = (
      @loan.loan_media(limit: 100, images_only: true) +
      @loan.log_media(limit: 100, images_only: true)
    ).in_groups_of(4, false)
  end
end
