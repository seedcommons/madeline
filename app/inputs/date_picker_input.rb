class DatePickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    input_html_options[:"data-date-format"] = "yyyy-mm-dd"
    input_html_options[:"data-provide"] = "datepicker"
    input_html_classes.push "form-control"
    @builder.text_field(attribute_name, input_html_options)
  end
end
