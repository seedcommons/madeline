class DecoratedNumericInput < SimpleForm::Inputs::NumericInput
  def input(wrapper_options = nil)
    # copied from source NumericInput (https://github.com/plataformatec/simple_form/blob/master/lib/simple_form/inputs/numeric_input.rb)
    input_html_classes.unshift("numeric")
    if html5?
      input_html_options[:type] ||= "number"
      input_html_options[:step] ||= integer? ? 1 : "any"
    end

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    # end copied from source

    prefix = options[:prefix]
    postfix = options[:postfix]

    template.content_tag(:div, class: 'decorated-numeric-input form-element') do
      if prefix.present?
        template.concat(template.content_tag(:span, class: 'input-prefix') do
          template.concat prefix
        end)
      end
      template.concat @builder.text_field(attribute_name, merged_input_options)
      if postfix.present?
        template.concat(template.content_tag(:span, class: 'input-postfix') do
          template.concat postfix
        end)
      end
    end
  end
end
