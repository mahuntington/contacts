class Person
    # connect to postgres
    DB = PG.connect(host: "localhost", port: 5432, dbname: 'contacts')

    def self.all
        results = DB.exec("SELECT * FROM people;")
        results.each do |result|
            puts result
        end
        [
            { name: 'Joey', age:12 },
            { name: 'Sarah', age:52 },
            { name: 'Cthulhu', age: 8000 }
        ]
    end
end
