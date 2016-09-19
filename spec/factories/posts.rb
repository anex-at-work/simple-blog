FactoryGirl.define do
  factory :post do
    name Faker::Lorem.sentence
    content Faker::Lorem.paragraphs((3..6).to_a.sample).join("\n\n")

    transient do
      comments_count 3
    end

    factory :post_with_comments do
      after :create do |post, evaluator|
        create_list :comment, evaluator.comments_count, post: post
      end
    end

    factory :post_with_tags do
      tags Faker::Lorem.words((2..4).to_a.sample)
    end
  end
end
