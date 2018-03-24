class JobsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        render json: Job.all
    end

    def show
        render json: Job.find(params["id"])
    end

    def create
        render json: Job.create(params["job"])
    end

    def delete
        render json: Job.delete(params["id"])
    end

    def update
        render json: Job.update(params["id"], params["job"])
    end
end
