class Person
    attr_reader :id, :name, :age, :home, :employers
    # connect to postgres
    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def initialize(opts = {})
        @id = opts["id"].to_i
        @name = opts["name"]
        @age = opts["age"].to_i
        if opts["home"]
            @home = opts["home"]
        end
        if opts["employers"]
            @employers = opts["employers"]
        end
    end

    def self.all
        results = DB.exec(
            <<-SQL
                SELECT
                    people.*,
                    locations.street,
                    locations.city,
                    locations.state,
                    companies.id AS company_id,
                    companies.name AS company,
                    companies.industry
                FROM people
                LEFT JOIN locations
                    ON people.home_id = locations.id
                LEFT JOIN jobs
                    ON people.id = jobs.person_id
                LEFT JOIN companies
                    ON jobs.company_id = companies.id
            SQL
        )
        people = []
        last_person_id = nil
        results.each do |result|
            if result["id"] != last_person_id
                last_person_id = result["id"]
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
                new_person = Person.new(
                    {
                        "id" => result["id"],
                        "name" => result["name"],
                        "age" => result["age"],
                        "home" => home,
                        "employers" => []
                    }
                )
                people.push(new_person)
            end
            if result["company_id"]
                employer = Company.new({
                    "id" => result["company_id"],
                    "name" => result["company"],
                    "industry" => result["industry"]
                })
                people.last.employers.push(employer)
            end
        end
        return people
    end

    def self.find(id)
        results = DB.exec(
            <<-SQL
                SELECT
                    people.*,
                    locations.street,
                    locations.city,
                    locations.state,
                    companies.id AS company_id,
                    companies.name AS company,
                    companies.industry
                FROM people
                LEFT JOIN locations
                    ON people.home_id = locations.id
                LEFT JOIN jobs
                    ON people.id = jobs.person_id
                LEFT JOIN companies
                    ON jobs.company_id = companies.id
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
        employers = results.map do |result|
            Company.new({
                "id" => result["company_id"],
                "name" => result["company"],
                "industry" => result["industry"],
            })
        end
        person =  Person.new(
            {
                "id" => result["id"],
                "name" => result["name"],
                "age" => result["age"],
                "home" => home,
                "employers" => employers
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
