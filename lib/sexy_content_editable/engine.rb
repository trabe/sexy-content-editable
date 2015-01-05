module SexyContentEditable
  class Engine < ::Rails::Engine
    initializer 'sexy_content_editable.initialize' do
      config.to_prepare do
        ActiveSupport.on_load(:action_view) do

          include SexyContentEditable::FormTagHelper

          class ActionView::Helpers::FormBuilder
            include SexyContentEditable::FormBuilder
          end
        end
      end
    end
  end
end
