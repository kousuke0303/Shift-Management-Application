User.create!(name: "Admin User",
             email: "admin@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)

15.times do |n|
  name  = Faker::Name.name
  email = "kitchen-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               kitchen: true,
               hole: true,
               wash: true,
               hourly_wage: 900,
               password: password,
               password_confirmation: password)
end
               
15.times do |n|
  name  = Faker::Name.name
  email = "hole-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               kitchen: false,
               hole: true,
               wash: true,
               hourly_wage: 900,
               password: password,
               password_confirmation: password)
end

30.times do |n|
  Attendance.create!(day: Date.current,
               work_start_time: Time.current,
               break_start_time: Time.current,
               break_end_time: Time.current,
               work_end_time: Time.current,
               salary: 9000,
               user_id: n+1)
end
