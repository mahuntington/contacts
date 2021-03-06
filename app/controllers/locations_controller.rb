class LocationsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        render json: Location.all
    end

    def show
        render json: Location.find(params["id"])
    end

    def create
        created_location = Location.create(params["location"])
        if params["id"]
            updated_person = Person.setHome(params["id"], created_location)
            created_location.inhabitants.push(updated_person)
        end
        render json: created_location
    end

    def delete
        render json: Location.delete(params["id"])
    end

    def update
        render json: Location.update(params["id"], params["location"])
    end
end
