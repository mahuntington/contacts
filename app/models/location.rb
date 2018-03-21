class Location
    # connect to postgres
    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def initialize(opts = {})
        @id = opts["id"].to_i
        @street = opts["street"]
        @city = opts["city"]
        @state = opts["state"]
    end

    def self.all
        results = DB.exec("SELECT * FROM locations;")
        return results.map { |result| Location.new(result) }
    end

    def self.find(id)
        results = DB.exec("SELECT * FROM locations WHERE id=#{id};")
        return Location.new(results.first)
    end

    def self.create(opts={})
        results = DB.exec("INSERT INTO locations (street, city, state) VALUES ( '#{opts["street"]}', '#{opts["city"]}', '#{opts["state"]}' );")
        return { created:true }
    end

    def self.delete(id)
        results = DB.exec("DELETE FROM locations WHERE id=#{id};")
        return { deleted: true }
    end

    def self.update(id, opts={})
        results = DB.exec("UPDATE locations SET street='#{opts["street"]}', city='#{opts["city"]}', state='#{opts["state"]}' WHERE id=#{id} ;")
        return { updated: true }
    end
end
