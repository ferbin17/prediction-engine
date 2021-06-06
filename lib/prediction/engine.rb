module Prediction
  class Engine < ::Rails::Engine
    isolate_namespace Prediction
    initializer "prediction.assets.precompile" do |app|
      app.config.assets.precompile << "prediction_manifest.js"
    end
    
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      html_tag.html_safe
    end
  end
end
