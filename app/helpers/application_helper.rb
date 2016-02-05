module ApplicationHelper
  # adds "http://" if no protocol present
  def urlify(url)
    URI(url).scheme ? url : "http://" + url
  end
end
