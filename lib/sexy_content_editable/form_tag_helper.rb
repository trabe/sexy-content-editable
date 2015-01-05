module SexyContentEditable
  module FormTagHelper

    extend ActiveSupport::Concern

    def sexy_content_editable_tag(name, value = nil, options = {})
      data_options = options[:data] || {}
      data_options.merge! behaviour: 'sexy-content-editable'
      text_field_options = options.merge data: data_options
      text_field name, value, text_field_options
    end
  end
end
