FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :booking do
    zip_code "94609"
    booking_date 5.days.ago
  end

  factory :booking_detail do
    sequence(:rank) { |n| n }
  end

  factory :charge do
  end

  factory :charge_type do
    sequence(:score) { |n| 2 ** (n % 5) }
  end
end