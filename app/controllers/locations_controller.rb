class LocationsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        render json: Location.all
    end

    def show
        render json: Location.find(params["id"])
    end

    def create
        render json: Location.create(params["location"])
    end

    def delete
        render json: Location.delete(params["id"])
    end

    def update
        render json: Location.update(params["id"], params["location"])
    end
end
