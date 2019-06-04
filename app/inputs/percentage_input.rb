class PercentageInput < SimpleForm::Inputs::NumericInput
  def input(wrapper_options = nil)
      # copied from source
      input_html_classes.unshift("numeric")
      if html5?
        input_html_options[:type] ||= "number"
        input_html_options[:step] ||= integer? ? 1 : "any"
      end

      merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
      # end copied from source

      # out = ActiveSupport::SafeBuffer.new
      # out << @builder.text_field(attribute_name, merged_input_options)
      # out << @builder.label("%", class: "percentage_input")
      out = ActiveSupport::SafeBuffer.new
      # including form-element class means all of this is hidden on edit
      out << @builder.label(attribute_name, class: "percentage_input form-element") {
        @builder.text_field(attribute_name, merged_input_options) + " %"
      }
  end
end
