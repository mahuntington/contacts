class PeopleController < ApplicationController
    def index
        # render({ :json => { :message => 'hi', :status => 200 } })
        # render json: message: 'hi', status: 200 # doesn't work because nested objects are unguessable
        render json: { message: 'hi', status: 200 }
    end
end
