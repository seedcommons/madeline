module AdminHelper
  def authorized_form_field(simple_form: nil, model: nil, field_name: nil, choices: nil,
    include_blank_choice: true, classes: '')
    model_field = model.send(field_name)
    if model_field
      policy = "#{model_field.class.name}Policy".constantize.new(current_user, model_field)
      link_path = url_for([:admin, model_field])
    end

    render partial: 'admin/common/authorized_form_field', locals: {
      f: simple_form,
      model_field: model_field,
      field_name: field_name,
      id_field_name: "#{field_name}_id",
      link_path: link_path,
      choices: choices,
      include_blank_choice: include_blank_choice,
      may_show_link: model_field && policy.show?,
      # Beware, if the 'may_edit' logic changes and might be false even with a non-nil model_field,
      # then the paratial code will also need updating to make nil safe.
      may_edit: !model_field || policy.show?,
      classes: classes
    }
  end

  def admin_custom_colors
    return @admin_custom_colors if @admin_custom_colors
    colors = {}
    colors[:banner_fg] = selected_division && selected_division.banner_fg_color || "white"
    colors[:banner_bg] = selected_division && selected_division.banner_bg_color || "#8C2426"
    colors[:accent_main] = selected_division && selected_division.accent_main_color || colors[:banner_bg]
    colors[:accent_fg_text] = selected_division && selected_division.accent_fg_color || colors[:banner_fg]

    # These two colors are derived from the user configurable ones using the Chroma gem.
    colors[:accent_darkened] = begin
      colors[:accent_main].paint.darken(5)
    rescue Chroma::Errors::UnrecognizedColor
      colors[:accent_main]
    end

    colors[:banner_fg_transp] = begin
      # Add alpha channel
      colors[:banner_fg].paint.tap { |c| c.rgb.a = 0.3 }.to_rgb
    rescue Chroma::Errors::UnrecognizedColor
      colors[:banner_fg]
    end

    @admin_custom_colors = colors
  end

  # This should be updated whenever columns are added/removed to the timeline table
  def timeline_table_step_column_count
    8
  end

  # For displaying tree structure in dropdowns
  def indented_option_label(node, label_method)
    # Subtract 1 from depth since root node either doesn't display or displays as "[None]"
    ("&nbsp; &nbsp; " * [node.depth - 1, 0].max).html_safe << node.send(label_method)
  end

  # Displays Font Awesome icons
  def icon_tag(class_name, options: {})
    content_tag(:i, "", id: options[:id], data: options[:data], class: "fa fa-#{class_name} #{options[:extra_classes]}")
  end

  def documentation_popover(documentations, html_identifier: "")
    documentation = documentations[html_identifier]
    if documentation.present?
      data_content = documentation&.summary_content.to_s
      if documentation.page_content.present?
        learn_more_link = link_to t("documentation.learn_more"), admin_documentation_path(documentation), target: :_blank
        data_content << "<br /><br />" << learn_more_link
      end
      action_link = link_to icon_tag("pencil"), edit_admin_documentation_path(documentation), id: "#{html_identifier}-edit-link" if policy(documentation).edit?
    else
      new_documentation = Documentation.new
      return "" unless policy(new_documentation).new?
      caller_string = "#{controller_name}##{action_name}"
      data_content = t("documentation.no_documentations")
      action_link = link_to icon_tag("plus"),
        new_admin_documentation_path(caller: caller_string, html_identifier: html_identifier), id: "#{html_identifier}-new-link" if policy(new_documentation).new?
      extra_classes = "text-muted"
    end
    title_content = content_tag(:span, action_link, class: "text-right")
    data_hash = { toggle: "popover", content: data_content, html: true, title: title_content }
    content_tag(:a, tabindex: 0, data: data_hash, class: 'ms-popover ms-documentation', id: "#{html_identifier}-link") do
      icon_tag("question-circle", options: {id: html_identifier, extra_classes: extra_classes})
    end
  end
end
