User.create!(name: "Admin User",
             tel: "09011112222",
             email: "admin@email.com",
             hourly_wage: 900,
             password: "password",
             password_confirmation: "password",
             admin: true)

5.times do |n|
  name  = Faker::Name.name
  email = "kitchen-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               tel: "09011112222",
               email: email,
               kitchen: true,
               hole: true,
               wash: true,
               hourly_wage: 900,
               password: password,
               password_confirmation: password)
end
               
5.times do |n|
  name  = Faker::Name.name
  email = "hole-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               tel: "09011112222",
               email: email,
               kitchen: false,
               hole: true,
               wash: true,
               hourly_wage: 900,
               password: password,
               password_confirmation: password)
end
