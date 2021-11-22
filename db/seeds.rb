# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

case Rails.env
when "development"
    puts "Adding users"
    5.times do |i|
        attributes = {
          "email": Faker::Internet.email,
          "password": "123456",
        }
        user = User.new(attributes)
        user.save!
    end
    puts "Finished adding users"
    puts "Adding Todos"
    User.all.each do |user|
        rand(1..3).times do |i|
            todo = Todo.create(
                title: "Title ##{i}",
                description: "Description #{i}",
                user_id: user.id
            )
        end
    end
    puts "Finished adding todos"
end