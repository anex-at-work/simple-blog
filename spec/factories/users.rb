FactoryGirl.define do
  factory :user do
    sequence :email do
      Faker::Internet.safe_email
    end
    sequence :username do
      Faker::Internet.user_name
    end
    password 'pass'
    password_confirmation 'pass'

    factory :user_with_posts do
      transient do
        posts_count 3
      end

      after :create do |user, evaluator|
        create_list :post, evaluator.posts_count, user: user
      end
    end
  end
end
