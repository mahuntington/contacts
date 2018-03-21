class CompaniesController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        render json: Company.all
    end

    def show
        render json: Company.find(params["id"])
    end

    def create
        render json: Company.create(params["company"])
    end

    def delete
        render json: Company.delete(params["id"])
    end

    def update
        render json: Company.update(params["id"], params["company"])
    end
end
