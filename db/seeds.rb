puts "Seeding data..."

User.destroy_all
Organization.destroy_all

admin_email = ENV["GLOBAL_ADMIN_EMAIL"]
admin_password = ENV["GLOBAL_ADMIN_PASSWORD"]
admin_security_answer = ENV["GLOBAL_ADMIN_SECURITY_ANSWER"]
admin_security_question = ENV["GLOBAL_ADMIN_SECURITY_QUESTION"]

raise "Missing admin ENV vars" unless admin_email && admin_password && admin_security_answer

# Create Global Admin
if User.where(role: :global_admin).empty?
  global_admin = User.create!(
    email: admin_email,
    password: admin_password,
    role: User::GLOBAL_ADMIN,
    organization: nil, # Global admin does not belong to any organization
    active: true,
    security_question: admin_security_question,
    security_answer_digest: BCrypt::Password.create(admin_security_answer)
  )

  puts "Created global admin #{global_admin.email}"
end

# Create Organizations
3.times do |i|
  org = Organization.create!(name: "Org #{i + 1}")

  # Create Org Admin
  org_admin = org.users.create!(
    email: "orgadmin#{i + 1}@example.com",
    password: "orgadmin",
    role: User::ORG_ADMIN,
    organization: org,
    active: true
  )

  puts "Created #{org.name} and org admin #{org_admin.email}"

  # Create Teachers
  2.times do |t|
    teacher = org.users.create!(
      email: "teacher#{i + 1}_#{t + 1}@example.com",
      password: "teacher",
      role: User::TEACHER,
      organization: org,
      active: true
    )

    puts "Created teacher #{t} #{teacher.email}"
  end

  # Create Students
  3.times do |s|
    student = org.users.create!(
      email: "student#{i + 1}_#{s + 1}@example.com",
      password: "student",
      role: User::STUDENT,
      organization: org,
      active: true
    )

    puts "Created student #{s} #{student.email}"
  end
end

puts "Done seeding users and organizations."
