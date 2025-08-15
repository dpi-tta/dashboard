# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_16_202614) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "attendances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "title"
    t.string "category", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "roll_taker_id", null: false
    t.uuid "cohort_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "attendees_count", default: 0, null: false
    t.index ["cohort_id"], name: "index_attendances_on_cohort_id"
    t.index ["roll_taker_id"], name: "index_attendances_on_roll_taker_id"
  end

  create_table "attendees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "attendance_id", null: false
    t.uuid "enrollment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_id", "enrollment_id"], name: "index_attendees_on_attendance_id_and_enrollment_id", unique: true
    t.index ["attendance_id"], name: "index_attendees_on_attendance_id"
    t.index ["enrollment_id"], name: "index_attendees_on_enrollment_id"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.uuid "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.uuid "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.uuid "creator_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.uuid "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "canvas_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "excluded", default: false
    t.integer "points_possible"
    t.string "name"
    t.string "id_from_canvas"
    t.integer "weight"
    t.integer "html"
    t.integer "ruby"
    t.integer "rails"
    t.uuid "cohort_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "css"
    t.integer "databases"
    t.integer "authentication"
    t.integer "domain_modeling"
    t.integer "javascript"
    t.index ["cohort_id"], name: "index_canvas_assignments_on_cohort_id"
  end

  create_table "canvas_gradebook_snapshots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "downloaded_at"
    t.string "csv_filename"
    t.uuid "cohort_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cohort_id"], name: "index_canvas_gradebook_snapshots_on_cohort_id"
    t.index ["user_id"], name: "index_canvas_gradebook_snapshots_on_user_id"
  end

  create_table "canvas_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "canvas_assignment_id", null: false
    t.uuid "enrollment_id", null: false
    t.float "points"
    t.uuid "canvas_gradebook_snapshot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canvas_assignment_id"], name: "index_canvas_submissions_on_canvas_assignment_id"
    t.index ["canvas_gradebook_snapshot_id"], name: "index_canvas_submissions_on_canvas_gradebook_snapshot_id"
    t.index ["enrollment_id"], name: "index_canvas_submissions_on_enrollment_id"
  end

  create_table "cohorts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "year", null: false
    t.integer "month", null: false
    t.integer "number", null: false
    t.string "piazza_course_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "canvas_shortname"
    t.date "started_on"
    t.string "discord_server_id"
  end

  create_table "devto_articles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "devto_id"
    t.string "title"
    t.string "url"
    t.datetime "published_at"
    t.text "description"
    t.uuid "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "social_image"
    t.index ["author_id"], name: "index_devto_articles_on_author_id"
  end

  create_table "enrollments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "role"
    t.uuid "user_id", null: false
    t.uuid "cohort_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "id_from_canvas"
    t.integer "career_total", default: 0
    t.text "career_summary"
    t.integer "career_attendance", default: 0
    t.integer "career_punctuality", default: 0
    t.integer "career_workplace_appearance", default: 0
    t.integer "career_workplace_culture", default: 0
    t.integer "career_taking_initiative", default: 0
    t.integer "career_quality_of_work", default: 0
    t.integer "career_networking", default: 0
    t.integer "career_response_to_supervision", default: 0
    t.integer "career_teamwork", default: 0
    t.integer "career_customer_service", default: 0
    t.integer "career_problem_solving", default: 0
    t.integer "career_calendar_management", default: 0
    t.integer "career_task_management", default: 0
    t.integer "communication_total", default: 0
    t.text "communication_summary"
    t.integer "communication_nonverbal", default: 0
    t.integer "communication_verbal", default: 0
    t.integer "communication_written", default: 0
    t.integer "technical_progress", default: 0
    t.integer "technical_good_questions", default: 0
    t.text "emotional_intelligence"
    t.text "staff_strengths"
    t.text "staff_areas_for_growth"
    t.text "skills_development"
    t.string "technical_rating"
    t.index ["cohort_id"], name: "index_enrollments_on_cohort_id"
    t.index ["id_from_canvas"], name: "index_enrollments_on_id_from_canvas"
    t.index ["user_id", "cohort_id"], name: "index_enrollments_on_user_id_and_cohort_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "feedback_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "enrollment_id", null: false
    t.uuid "canvas_gradebook_snapshot_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.text "message", null: false
    t.boolean "sent", default: false
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canvas_gradebook_snapshot_id"], name: "index_feedback_reports_on_canvas_gradebook_snapshot_id"
    t.index ["enrollment_id", "canvas_gradebook_snapshot_id", "start_date", "end_date"], name: "index_feedback_reports_on_unique_constraint", unique: true
    t.index ["enrollment_id"], name: "index_feedback_reports_on_enrollment_id"
  end

  create_table "impressions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "author_id", null: false
    t.uuid "subject_id", null: false
    t.text "content", null: false
    t.text "emoji", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "staff_only", default: false
    t.index ["author_id"], name: "index_impressions_on_author_id"
    t.index ["subject_id"], name: "index_impressions_on_subject_id"
  end

  create_table "piazza_activity_breakdowns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "enrollment_id", null: false
    t.string "name"
    t.string "emails", null: false
    t.string "role", null: false
    t.string "groups"
    t.integer "days_online", null: false
    t.integer "posts", null: false
    t.integer "edits_to_posts", null: false
    t.integer "answers", null: false
    t.integer "edits_to_answers", null: false
    t.integer "followups", null: false
    t.integer "replies_to_followups", null: false
    t.integer "instructor_good_question", null: false
    t.integer "instructor_good_answer", null: false
    t.integer "instructor_good_comment", null: false
    t.integer "student_good_question", null: false
    t.integer "student_thanks_on_answer", null: false
    t.integer "student_helpful_on_followups", null: false
    t.integer "good_question_given", null: false
    t.integer "thanks_on_answers_given", null: false
    t.integer "helpful_on_followups_given", null: false
    t.integer "post_views", null: false
    t.integer "live_qa_upvotes", null: false
    t.uuid "piazza_activity_report_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id"], name: "index_piazza_activity_breakdowns_on_enrollment_id"
    t.index ["piazza_activity_report_id"], name: "index_piazza_activity_breakdowns_on_reports_id"
  end

  create_table "piazza_activity_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "activity_from", null: false
    t.datetime "activity_until", null: false
    t.string "csv_filename"
    t.uuid "cohort_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["cohort_id"], name: "index_piazza_activity_reports_on_cohort_id"
    t.index ["user_id"], name: "index_piazza_activity_reports_on_user_id"
  end

  create_table "recurring_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cohort_id"
    t.string "channel_id"
    t.text "message_content"
    t.time "scheduled_time"
    t.text "days_of_week", default: [], array: true
    t.string "frequency", default: "weekly", null: false
    t.string "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cohort_id"], name: "index_recurring_messages_on_cohort_id"
  end

  create_table "rfp_idea_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.text "details"
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "resource_id"
    t.string "resource_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "piazza_full"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_username"
    t.string "canvas_full"
    t.text "quote"
    t.string "personal_website"
    t.text "most_recent_role"
    t.text "languages"
    t.text "strengths"
    t.text "education"
    t.text "fun_fact"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.text "one_liner"
    t.text "skills_and_projects"
    t.text "career_highlights"
    t.string "headshot"
    t.string "devto_username"
    t.string "discord_id"
    t.string "discord_username"
    t.string "salesforce_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["github_username"], name: "index_users_on_github_username", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.string "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "attendances", "cohorts"
  add_foreign_key "attendances", "users", column: "roll_taker_id"
  add_foreign_key "attendees", "attendances"
  add_foreign_key "attendees", "enrollments"
  add_foreign_key "canvas_assignments", "cohorts"
  add_foreign_key "canvas_gradebook_snapshots", "cohorts"
  add_foreign_key "canvas_gradebook_snapshots", "users"
  add_foreign_key "canvas_submissions", "canvas_assignments"
  add_foreign_key "canvas_submissions", "canvas_gradebook_snapshots"
  add_foreign_key "canvas_submissions", "enrollments"
  add_foreign_key "devto_articles", "users", column: "author_id"
  add_foreign_key "enrollments", "cohorts"
  add_foreign_key "enrollments", "users"
  add_foreign_key "feedback_reports", "canvas_gradebook_snapshots"
  add_foreign_key "feedback_reports", "enrollments"
  add_foreign_key "impressions", "enrollments", column: "subject_id"
  add_foreign_key "impressions", "users", column: "author_id"
  add_foreign_key "piazza_activity_breakdowns", "enrollments"
  add_foreign_key "piazza_activity_breakdowns", "piazza_activity_reports"
  add_foreign_key "piazza_activity_reports", "cohorts"
  add_foreign_key "piazza_activity_reports", "users"
  add_foreign_key "recurring_messages", "cohorts"
end
