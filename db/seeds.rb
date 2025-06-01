puts "Seeding data..."

# Clear everything
Assessment.destroy_all
Assignment.destroy_all
Enrollment.destroy_all
Course.destroy_all
Organization.destroy_all
User.destroy_all

# ENV vars
admin_email = ENV["GLOBAL_ADMIN_EMAIL"]
admin_password = ENV["GLOBAL_ADMIN_PASSWORD"]
admin_security_answer = ENV["GLOBAL_ADMIN_SECURITY_ANSWER"]
admin_security_question = ENV["GLOBAL_ADMIN_SECURITY_QUESTION"]

raise "Missing admin ENV vars" unless admin_email && admin_password && admin_security_answer

# Global Admin
if User.where(role: :global_admin).empty?
  global_admin = User.create!(
    email: admin_email,
    password: admin_password,
    role: User::GLOBAL_ADMIN,
    organization: nil,
    active: true,
    security_question: admin_security_question,
    security_answer_digest: BCrypt::Password.create(admin_security_answer)
  )
  puts "Created global admin #{global_admin.email}"
end

# Create Organizations and Users
3.times do |i|
  org = Organization.create!(
    name: "Org #{i + 1}",
    organization_code: "ORG#{i + 1}CODE"
  )

  org_admin = org.users.create!(
    email: "orgadmin#{i + 1}@example.com",
    password: "orgadmin",
    role: User::ORG_ADMIN,
    active: true,
    organization: org
  )

  puts "Created #{org.name} and org admin #{org_admin.email}"

  teachers = []
  2.times do |t|
    teacher = org.users.create!(
      email: "teacher#{i + 1}_#{t + 1}@example.com",
      password: "teacher",
      role: User::TEACHER,
      active: true,
      organization: org
    )
    teachers << teacher
    puts "Created teacher #{t + 1}: #{teacher.email}"
  end

  students = []
  3.times do |s|
    student = org.users.create!(
      email: "student#{i + 1}_#{s + 1}@example.com",
      password: "student",
      role: User::STUDENT,
      active: true,
      organization: org
    )
    students << student
    puts "Created student #{s + 1}: #{student.email}"
  end

  # Create courses
  teachers.each_with_index do |teacher, idx|
    course = Course.create!(
      name: "Course #{idx + 1} Org#{i + 1}",
      course_code: "COURSE#{i + 1}_#{idx + 1}",
      semester: %w[Spring Summer Fall Winter].sample,
      month: idx + 1,
      year: 2025,
      is_completed: [ true, false ].sample,
      organization: org,
      user: teacher
    )

    puts "📘 Created course #{course.name} for #{teacher.email}"

    # Create 2 assignments per course
    assignments = []
    %w[Midterm Final].each_with_index do |label, a_idx|
      assignment = Assignment.create!(
        name: "#{label} #{course.name}",
        a_type: %w[exam assignment project quiz].sample,
        max_score: 50,
        deadline: Time.zone.now + (a_idx + 1).weeks,
        course: course,
        user: teacher
      )
      assignments << assignment
      puts "Created assignment #{assignment.name}"
    end

    # Enroll first 2 students to the course
    students.first(2).each do |student|
      enrollment = Enrollment.create!(
        user: student,
        course: course,
        status: %w[active dropped passed failed].sample,
        grade: 0.0
      )
      puts "Enrolled #{student.email} to #{course.name}"

      # For each assignment, create assessment per enrolled student
      assignments.each do |assignment|
        assessment = Assessment.create!(
          assignment: assignment,
          enrollment: enrollment,
          score: 0.0,
          submitted_at: nil
        )
        puts "Added assessment for #{student.email} on #{assignment.name}"
      end
    end
  end
end

puts "Done seeding users, organizations, courses, assignments, enrollments, and assessments."
