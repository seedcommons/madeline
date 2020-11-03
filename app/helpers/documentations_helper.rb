module DocumentationsHelper
  def documentation_title(documentation)
    label = content_tag(:strong, I18n.t("page_title"))
    content = documentation.page_title.to_s
    content = content.empty? ? "?" : content
    return "#{label}: #{content}".html_safe
  end

  def documentation_location(documentation)
    label = content_tag(:strong, I18n.t("documentation.location"))
    calling_controller = documentation.calling_controller
    calling_action = documentation.calling_action

    if calling_controller == calling_action
      content = calling_controller.humanize
    else
      content = "#{I18n.t("controllers.admin.#{calling_controller}")} #{calling_action.humanize}"
    end

    return "#{label}: #{content}".html_safe
  end

  def documentation_division(documentation)
    label = content_tag(:strong, I18n.t("common.division"))
    division = documentation.division
    content = link_to division.name, admin_division_path(division)

    return "#{label}: #{content}".html_safe
  end

  def documentation_edit(documentation)
    label = "#{icon_tag("pencil")} #{I18n.t("documentation.edit")}".html_safe
    content = link_to label, edit_admin_documentation_path(documentation)
    return content.html_safe
  end

  def documentation_content(documentation)
    return documentation&.summary_content&.to_s&.html_safe
  end
end
