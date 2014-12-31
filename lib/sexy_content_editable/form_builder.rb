module SexyContentEditable
  module FormBuilder
    def sexy_content_editable(method, options = {})
      binding.pry
      @template.sexy_content_editable_tag(@object_name, method, objectify_options(options))
    end
  end
end
