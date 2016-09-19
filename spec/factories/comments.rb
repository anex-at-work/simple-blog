FactoryGirl.define do
  factory :comment do
    comment Faker::Lorem.paragraph
    association :user, factory: :user
  end
end
