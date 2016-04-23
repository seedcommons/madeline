module ApplicationHelper
  # adds "http://" if no protocol present
  def urlify(url)
    URI(url).scheme ? url : "http://" + url
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
    display = datetime.strftime(t("time.formats.#{format}"))
    full = datetime.strftime(t('time.formats.full_tz'))
    %Q{<span title="#{full}">#{display}</span>}.html_safe
  end

  # Converts given object/value to json and runs through html_safe.
  # In Rails 4, this is necessary and sufficient to guard against XSS in JSON.
  def json(obj)
    obj.to_json.html_safe
  end
end
