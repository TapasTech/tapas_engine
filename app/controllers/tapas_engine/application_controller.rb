module TapasEngine
  class ApplicationController < ActionController::Base
    include TapasEngine::Concerns::ParamsPlugin
    include TapasEngine::Concerns::ErrorsPlugin
    
    def index
      render json: {message: 'OK'}.to_json
    end
  end
end
