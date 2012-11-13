FactoryGirl.define do
  factory :user do
    #sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"

    factory :confirmed_user do
      after_create do |user|
        #user.confirm!
      end
      factory :admin do
        admin true
      end
    end
  end

  factory :survey do
    user
    sequence(:name) { |n| "Example survey #{n}" }
  end

  factory :booking do
    survey
    zip_code "94609"
    booking_date 5.days.ago
  end

  factory :booking_detail do
    booking
    sequence(:rank) { |n| n }
    charge
  end

  factory :charge do
    charge_type
  end

  factory :charge_type do
    sequence(:score) { |n| 2 ** (n % 5) }
  end
end