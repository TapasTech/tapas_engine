module TapasEngine
  class DingdingUsersController < ApplicationController
    def index
      render json: {message: 'dingding users'}.to_json
    end
  end
end
