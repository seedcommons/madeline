module ApplicationHelper
  # adds "http://" if no protocol present
  def urlify(url)
    # Rescue block used to safely pass through raw value if invalid url is provided
    URI(url).scheme ? url : "http://#{url}" rescue url
  end

  # Format datetime with telescoping accuracy based on how distant it is:
  #   within last day: time only
  #   within 6 months: month and day only
  #   longer: month and year only
  # Show full datetime in html `title` attribute for hover
  def fuzzy_time(datetime)
    return unless datetime
    format = case Time.now - datetime
      when 0..24.hours then :time_only
      when 24.hours..6.months then :md_only
      else :my_only
    end
    display = l(datetime, format: format)
    full = l(datetime, format: "full_tz")
    %Q{<span title="#{full}">#{display}</span>}.html_safe
  end

  def ldate(date, format: nil)
    date ? l(date, format: format) : ""
  end

  # Converts given object/value to json and runs through html_safe.
  # In Rails 4, this is necessary and sufficient to guard against XSS in JSON.
  def json(obj)
    obj.to_json.html_safe
  end

  # Using Id instead of ID is Excel compatible
  def csv_id
    t(:id).capitalize
  end

  def division_policy(record)
    DivisionPolicy.new(current_user, record)
  end

  def organization_policy(record)
    OrganizationPolicy.new(current_user, record)
  end

  def person_policy(record)
    PersonPolicy.new(current_user, record)
  end

  def render_index_grid(grid)
    no_records = grid.current_page_records.length < 1
    render "admin/common/grid", no_records: no_records, grid: grid
  end

  # Returns the new disbursment url, as well as addtional loan and org information.
  # This information maybe be required, if the loan does not exist in the old system.
  def labase_new_disbursment_url(loan:)
    disbursment_transaction_type = 12
    labase_url('transactionManager.php', loan,
      'Preset': true, 'TransactionType': disbursment_transaction_type, 'Loan': loan.id)
  end

  # Returns the new repayment url, as well as addtional loan and org information.
  # This information maybe be required, if the loan does not exist in the old system.
  def labase_new_repayment_url(loan:)
    repayment_transaction_type = 57
    labase_url('transactionManager.php', loan,
      'Preset': true, 'TransactionType': repayment_transaction_type, 'Loan': loan.id)
  end

  # Returns the schedule url, as well as addtional loan and org information.
  # This information maybe be required, if the loan does not exist in the old system.
  def labase_schedule_url(loan:)
    labase_url('LoanSchedule.php', loan, 'LoanID': loan.id)
  end

  # Takes the page_url merges labase values, with loan values, and returns properly formatted URI
  def labase_url(page_url, loan, labase_query_values)
    base_uri = 'http://internal.labase.org/'
    uri = Addressable::URI.parse(base_uri + page_url)
    uri.query_values = labase_query_values.merge(to_query_values(loan)).merge(to_query_values(loan.organization))
    uri.to_s
  end

  # Returns serializable attribs as rails standard post data
  #
  # to_query_values(loan)
  # =>
  # {"loan[id]"=>1364,
  #  "loan[amount]"=>#<BigDecimal:7feb498d5658,'0.1E5',9(18)>,
  #  "loan[currency_id]"=>2 ... }
  def to_query_values(object)
    allowed_attribs = object.attributes.select do |_key, value|
      [Fixnum, String, BigDecimal, Date].any? { |type| value.is_a?(type) }
    end

    allowed_attribs.inject({}) { |acc, (key, value)| acc.update("#{object.class.to_s.downcase}[#{key}]" => value.to_s) }
  end
end
