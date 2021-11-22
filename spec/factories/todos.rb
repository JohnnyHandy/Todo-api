FactoryBot.define do
    factory :todo do
        association :user
        description {Faker::Quote.famous_last_words}
        title {Faker::Name.name}
    end
end