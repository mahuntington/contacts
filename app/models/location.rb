class Location
    attr_reader :id, :street, :city, :state, :inhabitants

    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def initialize(opts = {})
        @id = opts["id"].to_i
        @street = opts["street"]
        @city = opts["city"]
        @state = opts["state"]
        if opts["inhabitants"]
            @inhabitants = opts["inhabitants"]
        end
    end

    def self.all
        results = DB.exec(
            <<-SQL
                SELECT
                    locations.*,
                    people.id AS person_id,
                    people.name,
                    people.age
                FROM locations
                LEFT JOIN people
                ON locations.id = people.home_id
            SQL
        )
        locations = []
        last_location_id = nil
        results.each do |result|
            if result["id"] != last_location_id
                locations.push(
                    Location.new({
                        "id" => result["id"],
                        "street" => result["street"],
                        "city" => result["city"],
                        "state" => result["state"],
                        "inhabitants" => []
                    })
                )
                last_location_id = result["id"]
            end
            if result["person_id"]
                new_person = Person.new({
                    "id" => result["person_id"],
                    "name" => result["name"],
                    "age" => result["age"],
                })
                locations.last.inhabitants.push(new_person)
            end
        end
        return locations
    end

    def self.find(id)
        results = DB.exec(
            <<-SQL
                SELECT
                    locations.*,
                    people.id AS person_id,
                    people.name,
                    people.age
                FROM locations
                LEFT JOIN people
                ON locations.id = people.home_id
                WHERE locations.id=#{id};
            SQL
        )
        inhabitants = []
        results.each do |result|
            if result["person_id"]
                inhabitants.push Person.new({
                    "id" => result["person_id"],
                    "name" => result["name"],
                    "age" => result["age"]
                })
            end
        end

        return Location.new({
            "id" => results.first["id"],
            "street" => results.first["street"],
            "city" => results.first["city"],
            "state" => results.first["state"],
            "inhabitants" => inhabitants
        })
    end

    def self.create(opts={})
        results = DB.exec(
            <<-SQL
                INSERT INTO locations (street, city, state)
                VALUES ( '#{opts["street"]}', '#{opts["city"]}', '#{opts["state"]}' )
                RETURNING id, street, city, state;
            SQL
        )
        return Location.new(results.first)
    end

    def self.delete(id)
        results = DB.exec("DELETE FROM locations WHERE id=#{id};")
        return { deleted: true }
    end

    def self.update(id, opts={})
        results = DB.exec(
            <<-SQL
                UPDATE locations
                SET street='#{opts["street"]}', city='#{opts["city"]}', state='#{opts["state"]}'
                WHERE id=#{id}
                RETURNING id, street, city, state;
            SQL
        )
        return Location.new(results.first)
    end
end
