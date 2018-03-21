class Person
    # connect to postgres
    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def initialize(opts = {})
        @id = opts["id"].to_i
        @name = opts["name"]
        @age = opts["age"].to_i
    end

    def self.all
        results = DB.exec("SELECT * FROM people;")
        return results.map { |result| Person.new(result) }
    end

    def self.find(id)
        results = DB.exec("SELECT * FROM people WHERE id=#{id};")
        return Person.new(results.first)
    end

    def self.create(opts={})
        results = DB.exec("INSERT INTO people (name, age) VALUES ( '#{opts["name"]}', #{opts["age"]} );")
        return { created:true }
    end

    def self.delete(id)
        results = DB.exec("DELETE FROM people WHERE id=#{id};")
        return { deleted: true }
    end

    def self.update(id, opts={})
        results = DB.exec("UPDATE people SET name='#{opts["name"]}', age=#{opts["age"]} WHERE id=#{id} ;")
        return { updated: true }
    end
end
