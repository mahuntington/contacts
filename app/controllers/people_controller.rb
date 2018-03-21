class PeopleController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        render json: Person.all
    end

    def show
        render json: Person.find(params["id"])
    end

    def create
        render json: Person.create(params["person"])
    end

    def delete
        render json: Person.delete(params["id"])
    end

    def update
        render json: Person.update(params["id"], params["person"])
    end
end
