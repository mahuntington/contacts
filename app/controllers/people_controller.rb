class PeopleController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        render json: Person.all
    end

    def show
        render json: Person.find(params["id"])
    end

    def create
        if params["id"]
            params["person"]["home_id"] = params["id"].to_i
        else
            params["person"]["home_id"] = "NULL"
        end
        render json: Person.create(params["person"])
    end

    def delete
        render json: Person.delete(params["id"])
    end

    def update
        render json: Person.update(params["id"], params["person"])
    end
end
