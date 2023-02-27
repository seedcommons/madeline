namespace :madeline do
  # Note the Madeline Task model is a completely separate concept from a rake task
  desc "Create a PDF Loan Statement for Previous Year and add as an attachment to each loan"

  task generate_annual_loan_statements: :environment do
    sample_loan = Loan.find(3563)
    start_date = Time.zone.now.last_year.beginning_of_year
    end_date =  Time.zone.now.last_year.end_of_year
    av = ActionView::Base.new(Rails.root.join('app', 'views'))
    av.assign({
      :loan => sample_loan,
      :start_date => start_date,
      :end_date => end_date,
      :transactions => sample_loan.transactions.in_date_range(start_date, end_date)
    })
    f = File.new(file_name, 'w')
    f.puts(av.render(:template => "admin/loans/statement.html.slim"))
    Media.create({
      media_attachable: sample_loan,
      item: f,
      kind_value: 'document',
      featured: false,
      caption: "Loan Statement #{start_date} = #{end_date}"
      })
    f.close
  end
end
