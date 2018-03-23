class Person
    attr_reader :id, :name, :age, :home
    # connect to postgres
    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def initialize(opts = {})
        @id = opts["id"].to_i
        @name = opts["name"]
        @age = opts["age"].to_i
        if opts["home_id"]
            @home = Location.find(opts["home_id"].to_i)
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
                INSERT INTO people (name, age, home_id)
                VALUES ( '#{opts["name"]}', #{opts["age"]},  #{opts["home_id"] ? opts["home_id"] : "NULL"})
                RETURNING id, name, age, home_id;
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
                SET name='#{opts["name"]}', age=#{opts["age"]}, home_id=#{opts["home_id"] ? opts["home_id"] : "NULL"}
                WHERE id=#{id}
                RETURNING id, name, age, home_id;
            SQL
        )
        return Person.new(results.first)
    end

    def self.setHome(person_id, home)
        results = DB.exec(
            <<-SQL
                UPDATE people
                SET home_id = #{home.id}
                WHERE id = #{person_id}
                RETURNING id, name, age;
            SQL
        )
        return Person.new(results.first)
    end

    def self.findByHomeId(home_id)
        results = DB.exec("SELECT id, name, age FROM people WHERE home_id = #{home_id}")
        return results.map { |result| Person.new(result) }
    end
end
