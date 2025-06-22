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

puts "Seeded #{Patient.count} patients."
