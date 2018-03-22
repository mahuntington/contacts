class Company
    # connect to postgres
    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def initialize(opts = {})
        @id = opts["id"].to_i
        @name = opts["name"]
        @age = opts["industry"]
    end

    def self.all
        results = DB.exec("SELECT * FROM companies;")
        return results.map { |result| Company.new(result) }
    end

    def self.find(id)
        results = DB.exec("SELECT * FROM companies WHERE id=#{id};")
        return Company.new(results.first)
    end

    def self.create(opts={})
        results = DB.exec(
            <<-SQL
                INSERT INTO companies (name, industry)
                VALUES ( '#{opts["name"]}', '#{opts["industry"]}' )
                RETURNING id, name, industry;
            SQL
        )
        return Company.new(results.first)
    end

    def self.delete(id)
        results = DB.exec("DELETE FROM companies WHERE id=#{id};")
        return { deleted: true }
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
        return Company.new(results.first)
    end
end
