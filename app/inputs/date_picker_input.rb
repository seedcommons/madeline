class DatePickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    input_html_options[:"data-date-format"] = I18n.t("date.picker_format")
    input_html_options[:"data-provide"] = "datepicker"
    input_html_classes.push "form-control"

    if value.present?
      input_html_options[:value] = I18n.localize(value)
    end

    @builder.text_field(attribute_name, input_html_options)
  end

  private

  def value
    object.send(attribute_name) if object.respond_to?(attribute_name)
  end
end
