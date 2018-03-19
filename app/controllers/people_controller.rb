class PeopleController < ApplicationController
    def index
        render json: [
            { name: 'Joey', age:12 },
            { name: 'Sarah', age:52 },
            { name: 'Cthulhu', age: 8000 }
        ]
    end
end
