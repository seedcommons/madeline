module FormHelper
  def error_notification(f, dont_show_default: false)
    default = dont_show_default ? "" : f.error_notification

    base = if f.object.errors[:base].present?
      content_tag(:div, class: "alert alert-danger") do
        f.object.errors[:base].join(", ")
      end
    else
      ""
    end

    "".html_safe << default << base
  end

  def dropdown_options(constant_array, i18n_prefix)
    constant_array.map { |c| [t("#{i18n_prefix}.#{c}"), c] }
  end
end
