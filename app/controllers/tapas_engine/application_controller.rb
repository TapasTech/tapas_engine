module TapasEngine
  class ApplicationController < ActionController::Base
    include ParamsPlugin
    
    def index
      render json: {message: 'OK'}.to_json
    end
  end
end
