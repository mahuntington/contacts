class Company
    # connect to postgres
    DB = PG.connect({:host => "localhost", :port => 5432, :dbname => 'contacts'})

    def self.all
        results = DB.exec(
            <<-SQL
                SELECT
                    companies.*,
                    people.id AS person_id,
                    people.name AS person_name,
                    people.age
                FROM companies
                LEFT JOIN jobs
                    ON companies.id = jobs.company_id
                LEFT JOIN people
                    ON jobs.person_id = people.id;
            SQL
        )
        companies = []
        last_company_id = nil;
        results.each do |result|
            if result["id"] != last_company_id
                company = {
                    "id" => result["id"].to_i,
                    "name" => result["name"],
                    "industry" => result["industry"],
                    "employees" => []
                };
                companies.push(company)
                last_company_id = result["id"]
            end
            if result["person_id"]
                companies.last["employees"].push({
                    "id" => result["person_id"].to_i,
                    "name" => result["person_name"],
                    "age" => result["age"].to_i,
                })
            end
        end
        return companies
    end

    def self.find(id)
        results = DB.exec(<<-SQL
                SELECT
                    companies.*,
                    people.id AS person_id,
                    people.name AS person_name,
                    people.age
                FROM companies
                LEFT JOIN jobs
                    ON companies.id = jobs.company_id
                LEFT JOIN people
                    ON jobs.person_id = people.id
                WHERE companies.id=#{id};
            SQL
        )
        employees = [];
        results.each do |result|
            if result["person_id"]
                employees.push({
                    "id" => result["person_id"].to_i,
                    "name" => result["person_name"],
                    "age" => result["age"].to_i,
                })
            end
        end
        return {
            "id" => results.first["id"].to_i,
            "name" => results.first["name"],
            "industry" => results.first["industry"],
            "employees" => employees
        }
    end

    def self.create(opts={})
        results = DB.exec(
            <<-SQL
                INSERT INTO companies (name, industry)
                VALUES ( '#{opts["name"]}', '#{opts["industry"]}' )
                RETURNING id, name, industry;
            SQL
        )
        return {
            "id" => results.first["id"].to_i,
            "name" => results.first["name"],
            "industry" => results.first["industry"]
        }
    end

    def self.delete(id)
        results = DB.exec("DELETE FROM companies WHERE id=#{id};")
        return { "deleted" => true }
    end

    def self.update(id, opts={})
        results = DB.exec(
            <<-SQL
                UPDATE companies
                SET name='#{opts["name"]}', industry='#{opts["industry"]}'
                WHERE id=#{id}
                RETURNING id, name, industry;
            SQL
        )
        return {
            "id" => results.first["id"].to_i,
            "name" => results.first["name"],
            "industry" => results.first["industry"]
        }
    end
end
