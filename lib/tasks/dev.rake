unless Rails.env.production?
  namespace :dev do
    desc "Destroy, re-create, re-seed, and re-prime the database"
    task reprime: [
      :environment,
      "db:drop",
      "db:create",
      "db:migrate",
      "db:seed",
      "dev:prime"
    ]

    desc "Hydrate the database with sample data"
    task prime: :environment do
      Time.use_zone("America/Chicago") do
        usernames = %w[alice bob carol]

        users = []

        usernames.each do |username|
          users << User.create(
            email: "#{username}@example.com",
            password: "password",
            github_username: username,
            first_name: username,
            last_name: "Example"
          )
        end

        cohort = Cohort.create(name: "Sample Cohort") do |c|
          c.year = 2022
          c.month = 1
          c.number = 2
          c.canvas_shortname = "WE-2022-1.2-SDF"
          c.started_on = "September 19th, 2022"
          c.discord_server_id = "1352007014330662962"
        end

        if cohort.errors.any?
          ap cohort.errors.full_messages
          ap cohort
        end

        # TODO: add users with different cohort roles
        # eg admin@dpi.dev, instructor@dpi.dev, teaching_assistant@dpi.dev, staff@dpi.dev
        test_users = [
          { email: "admin@dpi.dev", role: :admin },
          { email: "instructor@dpi.dev", role: :instructor },
          { email: "ta@dpi.dev", role: :teaching_assistant },
          { email: "staff@dpi.dev", role: :staff },
          { email: "student@dpi.dev", role: :student }
        ]

        test_users.each do |user_info|
          user = User.create(
            email: user_info[:email],
            first_name: user_info[:email].split("@").first.capitalize,
            last_name: "User",
            password: "password"
          )

          if user_info[:role] == :admin
            user.add_role(:admin)
          else
            cohort.enrollments.create(role: user_info[:role], user: user) if cohort
          end
        end

        sample_cohort_enrollment_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: Rails.root.join("lib/sample_data/sample-cohort-enrollment.csv").open,
          filename: "sample-cohort-enrollment.csv",
          type: "text/plain"
        )
        sample_cohort_enrollment_csv = SmarterCSV.process(sample_cohort_enrollment_file)
        sample_cohort_enrollment_csv.each do |row|
          user = User.create(
            email: row.fetch(:email),
            canvas_full: row.fetch(:name),
            password: "password",
            github_username: row.fetch(:name).gsub(/[^a-z0-9]/i, ""),
            quote: Faker::Quote.matz,
            personal_website: Faker::Internet.url,
            most_recent_role: Faker::Job.title,
            languages: Array.new(rand(3)) { Faker::Nation.language }.to_sentence,
            strengths: Array.new(3) { Faker::Superhero.power }.to_sentence,
            education: Faker::Educator.degree,
            fun_fact: Faker::Lorem.sentence(word_count: 10),
            first_name: row.fetch(:name).split(" ").at(0),
            last_name: row.fetch(:name).split(" ").at(1),
            one_liner: "Passionate professional with expertise in #{Faker::Job.title}.",
            skills_and_projects: Array.new(3) { Faker::ProgrammingLanguage.unique.name }.to_sentence,
            salesforce_id: SecureRandom.uuid
          )

          if user.errors.any?
            ap user.errors.full_messages
            ap user
          end

          enrollment = cohort.enrollments.create(
            user:,
            id_from_canvas: row.fetch(:id_from_canvas),
            role: row.fetch(:role),
            career_summary: Faker::Lorem.paragraph,
            career_attendance: rand(1..4),
            career_punctuality: rand(1..4),
            career_workplace_appearance: rand(1..4),
            career_workplace_culture: rand(1..4),
            career_taking_initiative: rand(1..4),
            career_quality_of_work: rand(1..4),
            career_networking: rand(1..4),
            career_response_to_supervision: rand(1..4),
            career_teamwork: rand(1..4),
            career_customer_service: rand(1..4),
            career_problem_solving: rand(1..4),
            career_calendar_management: rand(1..4),
            career_task_management: rand(1..4),
            communication_summary: Faker::Lorem.paragraph,
            communication_nonverbal: rand(1..4),
            communication_verbal: rand(1..4),
            communication_written: rand(1..4),
            technical_good_questions: rand(1..4),
            emotional_intelligence: Faker::Lorem.paragraph,
            staff_strengths: Array.new(3) { Faker::Superhero.power }.to_sentence,
            staff_areas_for_growth: Array.new(3) { Faker::Superhero.power }.to_sentence,
            skills_development: Array.new(3) { Faker::Hacker.adjective }.to_sentence
          )

          if enrollment.errors.any?
            ap enrollment.errors.full_messages
            ap enrollment
          end

          user.devto_articles.create(
            title: Faker::Book.title,
            description: Faker::Lorem.sentence,
            published_at: Faker::Time.between(from: DateTime.now - 365, to: DateTime.now),
            social_image: Faker::Avatar.image(set: "set2", bgset: "bg1")
          )

          User.with_role(:admin).each do |admin|
            5.times do |i|
              Impression.create(
                author_id: admin.id,
                subject_id: enrollment.id,
                content: Faker::Lorem.sentence,
                emoji: Impression::EMOJIS.keys.sample,
                staff_only: [ true, false ].sample,
                created_at: rand(1..5).week.ago
              )
            end
          end
        end

        cohort_start_date = Date.parse("2023-01-30")

        6.times do |i|
          uploaded_file = ActionDispatch::Http::UploadedFile.new(
            tempfile: Rails.root.join("lib", "sample_data", "piazza-activity-#{i}.csv").open,
            filename: "piazza-activity-#{i}.csv",
            type: "text/plain"
          )

          cohort.piazza_activity_reports.create(
            activity_from: cohort_start_date + i.weeks,
            activity_until: cohort_start_date + (i + 1).weeks,
            csv_file: uploaded_file,
            user: users.sample
          )
        end

        1.upto(4) do |i|
          filename = "2022-0#{i}-01T1#{i}00_Grades-WE-2022-1.2-SDF.csv"
          csv_file = ActionDispatch::Http::UploadedFile.new(
            tempfile: Rails.root.join("lib", "sample_data", filename).open,
            type: "text/plain",
            filename:
          )

          cohort.canvas_gradebook_snapshots.create(
            downloaded_at: cohort_start_date + (i + 1).weeks,
            user: users.sample,
            csv_file:
          )
        end

        attendance_categories = Attendance.categories.keys

        start_date = 8.weeks.ago.beginning_of_week

        (0..7).each do |week_offset|
          current_week = start_date + week_offset.weeks

          3.times do |event_index|
            event_day = rand(1..5)
            event_time = rand(9..16)

            occurred_at = current_week + event_day.days + event_time.hours

            attendance = cohort.attendances.create!(
              title: [
                "#{Faker::Educator.course_name}",
                "#{Faker::Hacker.adjective.titleize} #{Faker::Hacker.noun.titleize} Workshop",
                "#{Faker::ProgrammingLanguage.name} Deep Dive",
                "Team Building: #{Faker::Team.name}",
                "#{Faker::Job.field} Career Session"
              ].sample,
              category: attendance_categories.sample,
              occurred_at: occurred_at,
              roll_taker: users.sample
            )

            attendance_rate = rand(70..100) / 100.0

            student_enrollments = cohort.enrollments.student
            attending_students = student_enrollments.sample(
              (student_enrollments.count * attendance_rate).round
            )

            attending_students.each do |enrollment|
              attendance.attendees.create!(enrollment: enrollment)
            end
          end
        end
      end
    end
  end
end
