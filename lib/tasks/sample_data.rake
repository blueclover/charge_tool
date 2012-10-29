namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    #make_users
    make_charge_types
    make_charges
    make_charge_aliases
    #make_bookings
    #make_booking_details
  end
end

def make_users
  admin = User.create!(#name:     "Example User",
                       email:    "example@railstutorial.org",
                       password: "foobar",
                       password_confirmation: "foobar")
  admin.toggle!(:admin)
  99.times do |n|
    #name  = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password  = "password"
    User.create!(#name:     name,
                 email:    email,
                 password: password,
                 password_confirmation: password)
  end
end

def make_charge_types
  5.times do |n|
    ChargeType.create!(score: 2 ** (n % 5))
  end
end

def make_charges
  charge_types = ChargeType.all
  charge_types.each { |type| 10.times { type.charges.create! } }
end

def make_charge_aliases
  charges = Charge.all
  charges.each do |charge|
    2.times do |n|
      letter = ('a'..'z').to_a[n]
      charge.charge_aliases.create!(alias: "#{charge.id}#{letter}")
    end
  end
end

def make_bookings
  2.times do |n|
    Booking.create!(zip_code:     "94609",
                    booking_date: n.days.ago)
  end
end

def make_booking_details
  bookings = Booking.all
  bookings.each do |booking|
    n = 1
    6.times do
      n += 1
      charge = Charge.find(rand(1..50))
      booking.booking_details.create!(rank:   n,
                                      charge_id: charge.id)
    end
  end
end
