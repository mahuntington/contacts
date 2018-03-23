class Person
    attr_reader :id, :name, :age, :home
    # connect to postgres
    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def initialize(opts = {})
        @id = opts["id"].to_i
        @name = opts["name"]
        @age = opts["age"].to_i
        if opts["home"]
            @home = opts["home"]
        end
    end

    def self.all
        results = DB.exec(
            <<-SQL
                SELECT
                    people.*,
                    locations.street,
                    locations.city,
                    locations.state
                FROM people
                LEFT JOIN locations
                    ON people.home_id = locations.id
            SQL
        )
        return results.map do |result|
            if result["home_id"]
                home = Location.new(
                    {
                        "id" => result["home_id"],
                        "street" => result["street"],
                        "city" => result["city"],
                        "state" => result["state"],
                    }
                )
            else
                home = nil
            end
            Person.new(
                {
                    "id" => result["id"],
                    "name" => result["name"],
                    "age" => result["age"],
                    "home" => home,
                }
            )
        end
    end

    def self.find(id)
        results = DB.exec(
            <<-SQL
                SELECT
                    people.*,
                    locations.street,
                    locations.city,
                    locations.state
                FROM people
                LEFT JOIN locations
                    ON people.home_id = locations.id
                WHERE people.id=#{id};
            SQL
        )
        result = results.first
        if result["home_id"]
            home = Location.new(
                {
                    "id" => result["home_id"],
                    "street" => result["street"],
                    "city" => result["city"],
                    "state" => result["state"],
                }
            )
        else
            home = nil
        end
        person =  Person.new(
            {
                "id" => result["id"],
                "name" => result["name"],
                "age" => result["age"],
                "home" => home,
            }
        )
        return person
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
end
