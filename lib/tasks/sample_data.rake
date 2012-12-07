namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_charge_types
    make_charges
    make_charge_aliases
    make_surveys
    make_bookings
    make_booking_details
    make_filter_criteria
  end
end

def make_users
  admin = User.new(#name:     "Example User",
                       email:    "admin@cochs.org",
                       password: "foobar",
                       password_confirmation: "foobar")
  #admin.skip_confirmation!
  admin.save!
  admin.toggle!(:admin)
  5.times do |n|
    #name  = Faker::Name.name
    email = "user-#{n+1}@cochs.org"
    password  = "password"
    user = User.new(#name:     name,
                 email:    email,
                 password: password,
                 password_confirmation: password)
    #user.skip_confirmation!
    user.save!
  end
end

def make_charge_types
  #[0,8,4,4,16,1,2].each do |n|
  #  ChargeType.create!(score: n)
  #end
  populate_table('charge_types')
end

def make_charges
#  charge_types = ChargeType.all
#  charge_types.each { |type| 10.times { type.charges.create! } }
  populate_table('charges')
end

def make_charge_aliases
  #charges = Charge.all
  #charges.each do |charge|
  #  2.times do |n|
  #    letter = ('a'..'z').to_a[n]
  #    charge.charge_aliases.create!(alias: "#{charge.id}#{letter}")
  #  end
  #end
  populate_table('charge_aliases')
end

def make_surveys
  admin = User.find_by_email("admin@cochs.org")
  50.times do |n|
    admin.surveys.create!(name: "Example survey #{n}")
  end
  users = User.all(limit: 4)
  users.each do |user|
    5.times do |n|
      user.surveys.create!(name: "User #{user.id} survey #{n}")
    end
  end
end

def make_bookings
  surveys = Survey.all
  surveys.each do |survey|
    10.times do |n|
      survey.bookings.create!(zip_code:     "94609",
                              booking_date: n.days.ago)
    end
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

def make_filter_criteria
  { 1 => 1, 4 => -1 }.each do |key, value|
    fc = FilterCriterion.new(charge_type_id: key,
                             significance: value)
    fc.survey_id = 0
    fc.save!
  end
end

def populate_table(table)
  file_path = "setup/#{table}.csv"
  field_names = CSV.parse(File.open(file_path, &:readline))[0]

  created_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")

  CSV.foreach(file_path, {headers: :first_row}) do |row|
    sql_vals = []

    field_names.each do |column|
      val = row[column]
      sql_vals << ActiveRecord::Base.connection.quote(val)
    end

    sql = "INSERT INTO #{table} " +
        "(#{field_names.join(', ')}, created_at, updated_at) " +
        "VALUES " +
        "(#{sql_vals.join(', ')}, '#{created_at}', '#{created_at}')"
    ActiveRecord::Base.connection.insert(sql)
  end
end