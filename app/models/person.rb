class Person
    # connect to postgres
    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def initialize(opts = {})
        @id = opts["id"].to_i
        @name = opts["name"]
        @age = opts["age"].to_i
        if opts["home_id"]
            @home_id = opts["home_id"]
        end
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
        results = DB.exec(
            <<-SQL
                INSERT INTO people (name, age)
                VALUES ( '#{opts["name"]}', #{opts["age"]} )
                RETURNING id, name, age;
            SQL
        )
        return Person.new(results.first)
    end

    def self.delete(id)
        results = DB.exec("DELETE FROM people WHERE id=#{id};")
        return { deleted: true }
    end

    def self.update(id, opts={})
        results = DB.exec(
            <<-SQL
                UPDATE people
                SET name='#{opts["name"]}', age=#{opts["age"]}
                WHERE id=#{id}
                RETURNING id, name, age;
            SQL
        )
        return Person.new(results.first)
    end
end
