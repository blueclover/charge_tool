FactoryGirl.define do
  factory :user do
    name     "JT"
    email    "it@cochs.org"
    password "foobar"
    password_confirmation "foobar"
  end
end