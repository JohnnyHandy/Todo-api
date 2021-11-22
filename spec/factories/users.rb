FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
  end
  trait :with_todos do
    after(:create) do |user|
      create(:todo, user_id: user.id)
    end
  end
end
