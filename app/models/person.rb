class Person
    def self.all # a static function that's called on the class itself, not an instance
        [ ## ruby functions return the last line of code, so no need for an explicit 'return' statement
            { name: 'Joey', age:12 },
            { name: 'Sarah', age:52 },
            { name: 'Cthulhu', age: 8000 }
        ]
    end
end
