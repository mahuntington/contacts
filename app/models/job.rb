class Job
    # connect to postgres
    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def self.all
        results = DB.exec("SELECT * FROM jobs;")
        return results.map do |result|
            {
                :id => result["id"].to_i,
                :person_id => result["person_id"].to_i,
                :company_id => result["company_id"].to_i,
            }
        end
    end

    def self.find(id)
        results = DB.exec("SELECT * FROM jobs WHERE id=#{id};")
        # return Job.new(results.first)
        return {
            :id => results.first["id"].to_i,
            :person_id => results.first["person_id"].to_i,
            :company_id => results.first["company_id"].to_i,
        }
    end

    def self.create(opts={})
        results = DB.exec(
            <<-SQL
                INSERT INTO jobs (person_id, company_id)
                VALUES ( #{opts["person_id"]}, #{opts["company_id"]} )
                RETURNING id, person_id, company_id;
            SQL
        )
        return {
            :id => results.first["id"].to_i,
            :person_id => results.first["person_id"].to_i,
            :company_id => results.first["company_id"].to_i,
        }
    end

    def self.delete(id)
        results = DB.exec("DELETE FROM jobs WHERE id=#{id};")
        return { deleted: true }
    end

    def self.update(id, opts={})
        results = DB.exec(
            <<-SQL
                UPDATE jobs
                SET person_id=#{opts["person_id"]}, company_id=#{opts["company_id"]}
                WHERE id=#{id}
                RETURNING id, person_id, company_id;
            SQL
        )
        return {
            :id => results.first["id"].to_i,
            :person_id => results.first["person_id"].to_i,
            :company_id => results.first["company_id"].to_i,
        }
    end
end
