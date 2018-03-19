class Person
    # connect to postgres
    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def initialize(opts = {})
        @id = opts["id"].to_i
        @name = opts["name"]
        @age = opts["age"]
    end

    def self.all
        results = DB.exec("SELECT * FROM people;")
        return results.map { |result| Person.new(result) }
    end
end
