module Prediction
  class Engine < ::Rails::Engine
    isolate_namespace Prediction
    initializer "prediction.assets.precompile" do |app|
      app.config.assets.precompile << "prediction_manifest.js"
    end
  end
end
