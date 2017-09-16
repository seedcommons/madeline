class DatePickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    # Picker language had to be set using $.fn.datepicker.defaults.language, in ApplicationView.
    # Could not get data tag to work.

    # We use a generic format for the picker because dealing with localized formats is a pain
    # on submission. Rails doesn't parse non-English formats very well.
    input_html_options[:"data-date-format"] = "yyyy-mm-dd"
    input_html_options[:"data-provide"] = "datepicker"
    input_html_classes.push "form-control"

    if value.present?
      input_html_options[:value] = I18n.localize(value, format: "%Y-%m-%d")
    end

    @builder.text_field(attribute_name, input_html_options)
  end

  private

  def value
    object.send(attribute_name) if object.respond_to?(attribute_name)
  end
end
