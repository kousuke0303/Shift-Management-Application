User.create!(name: "Admin User",
             email: "admin@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)

60.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               kitchen: false,
               hole: true,
               wash: true,
               password: password,
               password_confirmation: password)
end
