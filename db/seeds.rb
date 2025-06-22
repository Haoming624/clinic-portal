# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.destroy_all
Patient.destroy_all

User.create!(
  email: "reception@test.com",
  password: "password123",
  role: "receptionist"
)

User.create!(
  email: "doctor@test.com",
  password: "password123",
  role: "doctor"
)

Patient.create!([
  { name: "Alice Johnson", dob: Date.new(1990, 2, 14), notes: "Diabetic patient, regular checkups" },
  { name: "Bob Smith", dob: Date.new(1985, 6, 30), notes: "High blood pressure, prescribed medication" },
  { name: "Catherine Lee", dob: Date.new(2001, 11, 9), notes: "Recovering from surgery" }
])

# Generate 20 random patients with varied registration dates
20.times do |i|
  created_date = rand(0..60).days.ago
  Patient.create!(
    name: "Patient #{i + 1}",
    dob: Date.new(1950 + rand(70), rand(1..12), rand(1..28)),
    notes: "Generated patient for testing",
    status: Patient.statuses.keys.sample,
    created_at: created_date,
    updated_at: created_date
  )
end

puts "Seeded #{Patient.count} patients."
