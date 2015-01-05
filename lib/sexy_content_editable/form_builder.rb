module SexyContentEditable
  module FormBuilder

    def sexy_content_editable(method, options = {})
      @template.sexy_content_editable_tag(@object_name, method, objectify_options(options))
    end
  end
end
