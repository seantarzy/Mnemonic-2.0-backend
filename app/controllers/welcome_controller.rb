class WelcomeController < ApplicationController
    def index
        time = Time.now
        render json: "Time is now #{time}"
    end
end
