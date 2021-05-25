class BasicProject < Project
  attr_option_settable :status

  def start_date
    signing_date
  end

  def default_name
    I18n.t("common.untitled")
  end

  def display_name
    name.blank? ? default_name : name
  end

  def status
    status_label
  end

  def organization
    nil
  end
end
