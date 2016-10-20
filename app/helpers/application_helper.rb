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
end
