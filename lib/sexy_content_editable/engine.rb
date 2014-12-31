module SexyContentEditable
  class Engine < ::Rails::Engine
    initializer 'sexy_content_editable.initialize' do
      config.to_prepare do
        ActiveSupport.on_load(:action_view) do

          module ActionView::Helpers::FormTagHelper
            #include SexyContentEditable::FormTagHelper

    def sexy_content_editable_tag(name, value = nil, options = {})
      data_options = options[:data] || {}
      data_options.merge! behaviour: 'sexy-content-editable'
      text_area_options = options.merge data: data_options
      text_area name, value, text_area_options
    end
          end

          class ActionView::Helpers::FormBuilder
            include SexyContentEditable::FormBuilder
          end
        end
      end
    end
  end
end
