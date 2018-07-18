# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121017080436) do

  create_table "answers", :force => true do |t|
    t.integer  "question_id"
    t.text     "answer_text"
    t.string   "answer_status"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "answer_image_file_name"
    t.string   "answer_image_content_type"
    t.integer  "answer_image_file_size"
    t.integer  "question_bank_id"
    t.integer  "tenant_id"
  end

  add_index "answers", ["question_bank_id"], :name => "ans_question_bank_id_index"
  add_index "answers", ["question_id"], :name => "ans_question_id_index"

  create_table "assessment_components", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "assessment_courses", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "course_id"
    t.integer  "package_id"
    t.integer  "assessment_package_id"
    t.integer  "user_id"
    t.integer  "tenant_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "assessment_packages", :force => true do |t|
    t.string   "name"
    t.integer  "tenant_id"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "assessment_order"
  end

  create_table "assessment_questions", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "question_id"
    t.float    "mark"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.float    "negative_mark", :default => 0.0
  end

  add_index "assessment_questions", ["assessment_id"], :name => "aq_assessment_id_index"
  add_index "assessment_questions", ["question_id"], :name => "aq_question_id_index"

  create_table "assessment_rules", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "questions_required"
    t.integer  "questions_picked"
    t.integer  "tenant_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "section_id"
    t.float    "positive_mark",      :default => 1.0
    t.float    "negative_mark",      :default => 0.0
    t.integer  "question_bank_id"
    t.integer  "question_type_id"
    t.integer  "difficulty_id"
  end

  create_table "assessments", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "start_time",                          :default => '2012-06-07 05:52:41'
    t.float    "correct_ans_points",                  :default => 1.0
    t.float    "wrong_ans_points",                    :default => 0.0
    t.integer  "no_of_questions"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.integer  "user_id"
    t.string   "am_pm",                               :default => ""
    t.string   "show_status",                         :default => "off"
    t.string   "send_score_by_mail",                  :default => "off"
    t.text     "instruction_for_test"
    t.integer  "duration_hour",                       :default => 0
    t.integer  "duration_min",                        :default => 30
    t.string   "pass_score",                          :default => ""
    t.string   "assessment_type",                     :default => "multiple"
    t.datetime "end_time",                            :default => '2012-06-07 05:52:48'
    t.string   "schedule_type",                       :default => "open"
    t.string   "reattempt",                           :default => "on"
    t.string   "time_bound"
    t.integer  "demographics_id"
    t.integer  "tenant_id"
    t.boolean  "is_linear",                           :default => false
    t.boolean  "is_show_all",                         :default => true
    t.integer  "current_learner_id"
    t.integer  "total_learners",                      :default => 0
    t.integer  "no_of_attempted_learners",            :default => 0
    t.integer  "completed_learners",                  :default => 0
    t.integer  "incomplete_learners",                 :default => 0
    t.integer  "unattempted_learners",                :default => 0
    t.integer  "timeup_learners",                     :default => 0
    t.string   "groups_assigned"
    t.integer  "test_pattern_id"
    t.boolean  "skip_question",                       :default => true
    t.string   "show_question_wise_scoring",          :default => "off"
    t.integer  "assessment_package_id"
    t.boolean  "allow_improvement",                   :default => true
    t.integer  "no_of_questions_in_improvement_test", :default => 0
    t.boolean  "is_overall",                          :default => true
    t.integer  "overall_less_percentage",             :default => 0
    t.integer  "section_less_percentage",             :default => 0
    t.boolean  "demographics_compulsory",             :default => false
    t.boolean  "is_from_all_low_scoring",             :default => true
    t.integer  "no_of_less_scoring_sections",         :default => 0
    t.boolean  "show_question_explanation"
    t.string   "assessment_image_file_name"
    t.string   "assessment_image_content_type"
    t.integer  "assessment_image_file_size"
    t.boolean  "show_all_per_page",                   :default => false
    t.boolean  "using_rules",                         :default => false
  end

  add_index "assessments", ["user_id"], :name => "as_user_id_index"

  create_table "assessments_question_banks", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "question_bank_id"
    t.integer  "question_limit"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "assessments_question_banks", ["assessment_id"], :name => "aqb_assessment_id_index"
  add_index "assessments_question_banks", ["question_bank_id"], :name => "aqb_question_bank_id_index"

  create_table "blogs", :force => true do |t|
    t.string   "blog_name"
    t.string   "blog_title"
    t.string   "blog_type"
    t.text     "blog_content"
    t.string   "profile_photo_file_name"
    t.string   "profile_photo_content_type"
    t.integer  "profile_photo_file_size"
    t.datetime "profile_photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "rss_content"
    t.string   "author"
    t.string   "designation"
    t.string   "linkedin"
    t.string   "twitter"
    t.string   "blog"
    t.string   "facebook"
    t.string   "orkut"
    t.string   "website"
    t.string   "lionsher_url"
    t.string   "folder"
  end

  create_table "buyer_sellers", :force => true do |t|
    t.integer  "seller_user_id"
    t.integer  "course_id"
    t.integer  "buyer_user_id"
    t.integer  "no_of_license"
    t.integer  "price"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "course_payment_done", :default => false
    t.datetime "buyer_course_expiry"
  end

  create_table "calculated_data_assessments", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "tenant_id"
    t.integer  "started",       :default => 0
    t.integer  "in_process",    :default => 0
    t.integer  "completed",     :default => 0
    t.integer  "timed_out",     :default => 0
    t.integer  "incomplete",    :default => 0
    t.float    "lowest_score",  :default => 0.0
    t.float    "highest_score", :default => 0.0
    t.float    "average_score", :default => 0.0
    t.float    "sd_score",      :default => 0.0
    t.string   "lowest_time"
    t.string   "highest_time"
    t.string   "average_time"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "calculated_data_learner_assessments", :force => true do |t|
    t.integer  "learner_id"
    t.integer  "user_id"
    t.integer  "tenant_id"
    t.integer  "assessment_id"
    t.integer  "answered",         :default => 0
    t.integer  "answered_correct", :default => 0
    t.integer  "answered_wrong",   :default => 0
    t.integer  "questions_marked", :default => 0
    t.float    "total_score",      :default => 0.0
    t.string   "total_time",       :default => "0"
    t.float    "percentage",       :default => 0.0
    t.float    "percentile",       :default => 0.0
    t.integer  "rank",             :default => 0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "component_widget_variables", :force => true do |t|
    t.integer  "component_widget_id"
    t.integer  "report_variable_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.text     "report_text"
  end

  create_table "component_widgets", :force => true do |t|
    t.integer  "report_component_id"
    t.integer  "widget_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "coupons", :force => true do |t|
    t.text     "code"
    t.integer  "assessment_id"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.string   "status"
    t.integer  "assessment_package_id"
    t.string   "code_for_download"
    t.integer  "course_id"
    t.boolean  "email_authentication_required", :default => false
    t.integer  "package_id"
  end

  add_index "coupons", ["assessment_package_id"], :name => "cpn_assessment_package_id_index"

  create_table "courses", :force => true do |t|
    t.string   "course_name"
    t.text     "description"
    t.float    "duration"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.string   "path"
    t.string   "url"
    t.string   "typeofcourse"
    t.integer  "size",                 :default => 0
    t.string   "feedback",             :default => "checked"
    t.integer  "user_id"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "scorm_url_parameters"
    t.string   "course_objective"
    t.string   "learners_type"
    t.string   "domain"
    t.string   "keywords"
    t.float    "course_price"
    t.string   "lms_cs"
    t.string   "course_library"
    t.string   "vendor",               :default => "LionSher"
    t.integer  "duration_hour"
    t.integer  "duration_min"
    t.string   "schedule_type",        :default => "open"
    t.datetime "start_time",           :default => '2012-06-07 05:52:54'
    t.datetime "end_time",             :default => '2012-06-07 05:52:54'
    t.string   "reattempt",            :default => "on"
    t.boolean  "published",            :default => false
    t.boolean  "course_expiry",        :default => false
    t.boolean  "is_scorm",             :default => true
    t.integer  "tenant_id"
    t.integer  "total_learners",       :default => 0
    t.integer  "completed_learners",   :default => 0
    t.integer  "no_of_comments",       :default => 0
    t.float    "average_rating",       :default => 0.0
    t.integer  "total_no_of_ratings",  :default => 0
    t.integer  "no_of_rating_records", :default => 0
    t.integer  "incomplete_learners",  :default => 0
    t.integer  "unattempted_learners", :default => 0
    t.integer  "timeup_learners",      :default => 0
    t.string   "groups_assigned"
    t.integer  "no_of_reattempts",     :default => 30
    t.integer  "current_learner_id"
  end

  add_index "courses", ["course_name"], :name => "course_name_index"
  add_index "courses", ["user_id"], :name => "course_user_id_index"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "demographics", :force => true do |t|
    t.string   "demographic_type_1"
    t.string   "demographic_type_2"
    t.string   "demographic_type_3"
    t.string   "demographic_type_4"
    t.text     "demographic_option_1"
    t.text     "demographic_option_2"
    t.text     "demographic_option_3"
    t.text     "demographic_option_4"
    t.integer  "assessment_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "demographic_type_5"
    t.string   "demographic_type_6"
    t.string   "demographic_type_7"
    t.string   "demographic_type_8"
    t.string   "demographic_type_9"
    t.string   "demographic_type_10"
    t.string   "demographic_type_11"
    t.string   "demographic_type_12"
    t.string   "demographic_type_13"
    t.string   "demographic_type_14"
    t.string   "demographic_type_15"
    t.text     "demographic_option_5"
    t.text     "demographic_option_6"
    t.text     "demographic_option_7"
    t.text     "demographic_option_8"
    t.text     "demographic_option_9"
    t.text     "demographic_option_10"
    t.text     "demographic_option_11"
    t.text     "demographic_option_12"
    t.text     "demographic_option_13"
    t.text     "demographic_option_14"
    t.text     "demographic_option_15"
  end

  create_table "descriptive_answers", :force => true do |t|
    t.text     "answer"
    t.integer  "learner_id"
    t.integer  "question_id"
    t.integer  "user_id"
    t.integer  "admin_id"
    t.integer  "assessment_id"
    t.float    "marks"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "descriptive_answers", ["assessment_id"], :name => "da_assessment_id_index"
  add_index "descriptive_answers", ["learner_id"], :name => "da_learner_id_index"
  add_index "descriptive_answers", ["question_id"], :name => "da_question_id_index"
  add_index "descriptive_answers", ["user_id"], :name => "da_user_id_index"

  create_table "difficulties", :force => true do |t|
    t.string   "difficulty_value"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "directions", :force => true do |t|
    t.text     "direction_text"
    t.integer  "question_bank_id"
    t.integer  "tenant_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "emails", :force => true do |t|
    t.string   "email_type"
    t.string   "from"
    t.string   "subject"
    t.text     "body"
    t.integer  "tenant_id"
    t.integer  "user_id"
    t.boolean  "is_parsed",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["email_type"], :name => "email_type_index"
  add_index "emails", ["tenant_id"], :name => "email_tenant_id_index"

  create_table "errors", :force => true do |t|
    t.text     "error_text"
    t.integer  "tenant_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "group_name"
    t.integer  "user_id"
    t.integer  "tenant_id"
    t.integer  "no_of_learners"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "groups", ["group_name"], :name => "group_name_index"
  add_index "groups", ["user_id"], :name => "group_user_id_index"

  create_table "images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.string   "image_path"
    t.integer  "question_id"
    t.integer  "answer_id"
    t.integer  "tenant_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "imports", :force => true do |t|
    t.integer  "processed",          :default => 0
    t.string   "excel_file_name"
    t.string   "excel_content_type"
    t.integer  "excel_file_size"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "instructions", :force => true do |t|
    t.text     "instruction_text"
    t.integer  "structure_component_id"
    t.integer  "tenant_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "issues", :force => true do |t|
    t.string   "short_description"
    t.text     "detailed_description"
    t.string   "status"
    t.string   "issue_type"
    t.integer  "assigned_to"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.integer  "user_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "learner_questions", :force => true do |t|
    t.integer  "learner_id"
    t.integer  "user_id"
    t.integer  "assessment_id"
    t.integer  "question_bank_id"
    t.integer  "question_id"
    t.string   "answer"
    t.float    "score"
    t.string   "answer_status"
    t.string   "attempted_status"
    t.integer  "duration"
    t.integer  "tenant_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "assessment_rule_id"
  end

  create_table "learners", :force => true do |t|
    t.integer  "admin_id"
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "tenant_id"
    t.string   "lesson_location",             :default => ""
    t.string   "credit",                      :default => "credit"
    t.string   "entry",                       :default => "ab-initio"
    t.string   "lesson_exit"
    t.string   "lesson_status",               :default => "not attempted"
    t.string   "lesson_mode",                 :default => "normal"
    t.string   "score_raw",                   :default => ""
    t.string   "score_max",                   :default => ""
    t.string   "score_min",                   :default => ""
    t.string   "total_time",                  :default => "0000:00:00.00"
    t.string   "session_time"
    t.text     "suspend_data",                                                   :null => false
    t.text     "launch_data",                                                    :null => false
    t.integer  "rating",                      :default => 0
    t.text     "comments"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.integer  "assessment_id"
    t.string   "active",                      :default => "yes"
    t.datetime "test_start_time",             :default => '2012-06-07 05:52:42'
    t.string   "type_of_test_taker",          :default => "admin"
    t.text     "email_exception"
    t.string   "demographic_1"
    t.string   "demographic_2"
    t.string   "demographic_3"
    t.string   "demographic_4"
    t.integer  "no_of_times_attempted",       :default => 0
    t.float    "percentage",                  :default => 0.0
    t.float    "percentile",                  :default => 0.0
    t.float    "standard_deviation",          :default => 0.0
    t.integer  "rank",                        :default => 0
    t.integer  "group_id",                    :default => 1
    t.text     "marked_questions"
    t.text     "incomplete_questions"
    t.text     "attempted_questions"
    t.string   "enjoy_experience_answer"
    t.string   "time_alloted_answer"
    t.text     "suggest_a_question"
    t.text     "suggestions_for_improvement"
    t.text     "timestamps"
    t.text     "question_scores"
    t.text     "question_status_details"
    t.integer  "topic_wise_rank"
    t.integer  "topic_wise_percentile"
    t.string   "demographic_5"
    t.string   "demographic_6"
    t.string   "demographic_7"
    t.string   "demographic_8"
    t.string   "demographic_9"
    t.string   "demographic_10"
    t.string   "demographic_11"
    t.string   "demographic_12"
    t.string   "demographic_13"
    t.string   "demographic_14"
    t.string   "demographic_15"
    t.float    "assessment_score",            :default => 0.0
    t.integer  "package_id"
    t.datetime "recent_timestamp"
  end

  add_index "learners", ["active"], :name => "learner_active_index"
  add_index "learners", ["admin_id"], :name => "learner_admin_id_index"
  add_index "learners", ["assessment_id"], :name => "learner_assessment_id_index"
  add_index "learners", ["course_id"], :name => "learner_course_id_index"
  add_index "learners", ["group_id"], :name => "learner_group_id_index"
  add_index "learners", ["lesson_status"], :name => "learner_lesson_status_index"
  add_index "learners", ["tenant_id"], :name => "learner_tenant_id_index"
  add_index "learners", ["type_of_test_taker"], :name => "learner_type_of_test_taker_index"
  add_index "learners", ["user_id"], :name => "learner_user_id_index"

  create_table "mtfs", :force => true do |t|
    t.integer  "question_id"
    t.string   "match_item"
    t.string   "match_option"
    t.integer  "mtf_id"
    t.integer  "tenant_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "package_learners", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "packages", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "instructions"
    t.integer  "user_id"
    t.integer  "tenant_id"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.string   "schedule_type",              :default => "open"
    t.datetime "start_time",                 :default => '2012-07-10 10:17:15'
    t.datetime "end_time",                   :default => '2012-07-10 10:17:16'
    t.string   "reattempt",                  :default => "on"
    t.string   "time_bound"
    t.string   "package_image_file_name"
    t.string   "package_image_content_type"
    t.integer  "package_image_file_size"
  end

  create_table "passages", :force => true do |t|
    t.text     "passage_text"
    t.integer  "question_bank_id"
    t.integer  "tenant_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "posts", :force => true do |t|
    t.text     "message"
    t.integer  "user_id"
    t.integer  "issue_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pricing_plans", :force => true do |t|
    t.string   "plan_name"
    t.integer  "amount"
    t.integer  "no_of_users"
    t.integer  "space_in_gb"
    t.boolean  "allow_scorm",       :default => true
    t.boolean  "allow_nonscorm",    :default => true
    t.boolean  "allow_ppt",         :default => true
    t.boolean  "allow_flash",       :default => true
    t.boolean  "allow_pdf",         :default => true
    t.boolean  "allow_audio",       :default => true
    t.boolean  "allow_video",       :default => true
    t.boolean  "allow_assessments", :default => true
    t.float    "plan_expiry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "plan_group",        :default => "small"
    t.string   "plan_type",         :default => "private"
  end

  create_table "profile_details", :force => true do |t|
    t.integer  "learner_id"
    t.integer  "profile_id"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "profile_dropdown_values", :force => true do |t|
    t.integer  "profile_id"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "profiles", :force => true do |t|
    t.string   "field_name"
    t.string   "field_type"
    t.integer  "structure_component_id"
    t.integer  "tenant_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "pulse_surveys", :force => true do |t|
    t.string   "name"
    t.text     "email"
    t.text     "coupon_code"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.text     "emp_id"
    t.text     "date_of_joining"
    t.text     "salary_grade"
    t.text     "function"
    t.text     "location"
  end

  create_table "question_attributes", :force => true do |t|
    t.integer  "question_id"
    t.integer  "tenant_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "tagvalue_id"
    t.integer  "question_type_id"
    t.integer  "question_bank_id"
    t.integer  "topic_id"
    t.integer  "subtopic_id"
    t.integer  "difficulty_id"
    t.integer  "direction_id"
    t.integer  "passage_id"
    t.integer  "error_id"
    t.integer  "question_status_id"
  end

  add_index "question_attributes", ["difficulty_id"], :name => "ques_attr_difficulty_id_index"
  add_index "question_attributes", ["direction_id"], :name => "ques_attr_direction_id_index"
  add_index "question_attributes", ["error_id"], :name => "ques_attr_error_id_index"
  add_index "question_attributes", ["passage_id"], :name => "ques_attr_passage_id_index"
  add_index "question_attributes", ["question_bank_id"], :name => "ques_attr_question_bank_id_index"
  add_index "question_attributes", ["question_id"], :name => "ques_attr_question_id_index"
  add_index "question_attributes", ["question_status_id"], :name => "ques_attr_question_status_id_index"
  add_index "question_attributes", ["question_type_id"], :name => "ques_attr_question_type_id_index"
  add_index "question_attributes", ["subtopic_id"], :name => "ques_attr_subtopic_id_index"
  add_index "question_attributes", ["tenant_id"], :name => "ques_attr_tenant_id_index"
  add_index "question_attributes", ["topic_id"], :name => "ques_attr_topic_id_index"

  create_table "question_banks", :force => true do |t|
    t.string   "name"
    t.integer  "no_of_questions"
    t.integer  "user_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "type_of_question_bank"
    t.integer  "tenant_id"
  end

  add_index "question_banks", ["user_id"], :name => "qb_user_id_index"

  create_table "question_statuses", :force => true do |t|
    t.string   "status_value"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "question_tags", :force => true do |t|
    t.integer  "question_id"
    t.integer  "tagvalue_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "question_types", :force => true do |t|
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "questions", :force => true do |t|
    t.text     "question_text"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "question_image_file_name"
    t.string   "question_image_content_type"
    t.integer  "question_image_file_size"
    t.string   "error_in_question"
    t.integer  "question_bank_id"
    t.string   "question_type"
    t.integer  "mtf_id"
    t.float    "no_of_characters",            :default => 1.0
    t.string   "type_of_dtq"
    t.text     "explanation"
    t.text     "direction_text"
    t.datetime "expiry_date"
    t.integer  "tenant_id"
  end

  add_index "questions", ["id"], :name => "ques_id_index"
  add_index "questions", ["mtf_id"], :name => "ques_mtf_id_index"
  add_index "questions", ["question_bank_id"], :name => "ques_question_bank_id_index"

  create_table "report_components", :force => true do |t|
    t.string   "component_name"
    t.integer  "report_template_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "report_templates", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "for_whom"
  end

  create_table "report_variables", :force => true do |t|
    t.string   "name"
    t.string   "method_name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "reports", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "report_template_id"
    t.integer  "tenant_id"
    t.integer  "structure_component_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "for_whom"
  end

  create_table "rules", :force => true do |t|
    t.integer  "assessment_rule_id"
    t.integer  "tag_id"
    t.integer  "tagvalue_id"
    t.integer  "tenant_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "sections", :force => true do |t|
    t.string   "name"
    t.integer  "structure_component_id"
    t.integer  "tenant_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "assessment_id"
    t.integer  "duration_hour",          :default => 0
    t.integer  "duration_min",           :default => 30
    t.string   "time_bound"
  end

  create_table "smtp_settings", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",  :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "structure_components", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "assessment_component_id"
    t.integer  "tenant_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "is_saved",                :default => "false"
  end

  create_table "subscribes", :force => true do |t|
    t.string   "email"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "name"
    t.string   "phone_number"
    t.string   "type_of_user"
    t.integer  "course_id"
  end

  create_table "subtopics", :force => true do |t|
    t.string   "name"
    t.integer  "topic_id"
    t.integer  "question_bank_id"
    t.integer  "tenant_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "tenant_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tagvalues", :force => true do |t|
    t.string   "value"
    t.integer  "tag_id"
    t.integer  "tagvalue_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "tenants", :force => true do |t|
    t.string   "organization"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.integer  "user_id"
    t.string   "theme",                    :default => "gray"
    t.string   "text_color",               :default => "orange"
    t.string   "custom_url"
    t.string   "quarter",                  :default => "Q2"
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.string   "dynamic_quarter_values"
    t.integer  "current_year"
    t.string   "selected_quarter",         :default => "Current Quarter(Q2)"
    t.integer  "previous_year"
    t.string   "type_of_business"
    t.string   "company_website"
    t.string   "about_your_company"
    t.string   "zone"
    t.string   "is_expired",               :default => "false"
    t.datetime "expiry_date"
    t.integer  "pricing_plan_id"
    t.integer  "no_of_courses_bought",     :default => 0
    t.integer  "no_of_license",            :default => 0
    t.integer  "selected_plan_id"
    t.string   "type_of_tenant",           :default => "admin"
    t.float    "total_amount",             :default => 0.0
    t.integer  "no_of_licenses_sold",      :default => 0
    t.string   "bank_name"
    t.string   "account_name"
    t.string   "account_number"
    t.text     "postal_address"
    t.string   "linked_in"
    t.string   "facebook"
    t.string   "twitter"
    t.integer  "max_learner_credit"
    t.integer  "remaining_learner_credit"
  end

  add_index "tenants", ["custom_url"], :name => "tenant_custom_url_index"
  add_index "tenants", ["organization"], :name => "tenant_organization_index"
  add_index "tenants", ["pricing_plan_id"], :name => "tenant_pricing_plan_id_index"
  add_index "tenants", ["user_id"], :name => "tenant_user_id_index"

  create_table "test_details", :force => true do |t|
    t.integer  "learner_id"
    t.string   "attempted_status",       :default => "unanswered"
    t.integer  "question_bank_id"
    t.integer  "question_id"
    t.integer  "answer_id"
    t.string   "question_type"
    t.string   "learner_answer_text"
    t.string   "answer_status"
    t.integer  "user_id"
    t.integer  "tenant_id"
    t.float    "duration_spent",         :default => 0.0
    t.float    "score",                  :default => 0.0
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.string   "marked_status",          :default => "unmarked"
    t.float    "question_positive_mark"
    t.float    "question_negative_mark"
    t.integer  "serial_number"
    t.datetime "timestamp"
    t.integer  "section_id"
    t.integer  "assessment_id"
    t.datetime "section_start_time"
  end

  add_index "test_details", ["answer_id"], :name => "answer_id_on_test_details"
  add_index "test_details", ["answer_status"], :name => "answer_status_on_test_details"
  add_index "test_details", ["attempted_status"], :name => "attempted_status_on_test_details"
  add_index "test_details", ["learner_id"], :name => "learner_id_on_test_details"
  add_index "test_details", ["marked_status"], :name => "marked_status_on_test_details"
  add_index "test_details", ["question_bank_id"], :name => "question_bank_id_on_test_details"
  add_index "test_details", ["question_id"], :name => "question_id_on_test_details"
  add_index "test_details", ["tenant_id"], :name => "tenant_id_on_test_details"
  add_index "test_details", ["user_id"], :name => "user_id_on_test_details"

  create_table "test_patterns", :force => true do |t|
    t.string   "pattern_name"
    t.integer  "no_of_sections",         :default => 1
    t.boolean  "instructions"
    t.boolean  "topic_wise_timer"
    t.boolean  "random_order_questions"
    t.boolean  "question_wise_scoring"
    t.boolean  "skip_question"
    t.boolean  "view_attempted"
    t.boolean  "view_unattempted"
    t.boolean  "view_marked"
    t.boolean  "view_results"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "section_names"
    t.string   "questions_per_section"
    t.string   "duration_per_section"
    t.integer  "total_duration",         :default => 0
    t.boolean  "feedback"
    t.float    "correct_mark",           :default => 1.0
    t.float    "wrong_mark",             :default => 0.0
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.integer  "question_bank_id"
    t.integer  "tenant_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "transaction_logs", :force => true do |t|
    t.integer  "transaction_id"
    t.integer  "reference_no"
    t.string   "transaction_status"
    t.integer  "pricing_plan_id"
    t.integer  "user_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.text     "http_header"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "response_code"
    t.string   "response_message"
    t.string   "date_created"
    t.integer  "payment_id"
    t.integer  "merchant_refno"
    t.integer  "amount"
    t.string   "mode"
    t.string   "description"
    t.string   "is_flagged"
    t.integer  "transaction_id"
    t.integer  "tenant_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "payment_done"
    t.integer  "pricing_plan_id"
    t.string   "billing_address"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_postal_code"
    t.string   "billing_country"
    t.string   "billing_phone"
    t.string   "delivery_address"
    t.string   "delivery_city"
    t.string   "delivery_state"
    t.string   "delivery_postal_code"
    t.string   "delivery_country"
    t.string   "delivery_phone"
  end

  add_index "transactions", ["tenant_id"], :name => "transaction_tenant_id_index"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",           :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",            :limit => 40
    t.datetime "activated_at"
    t.string   "reset_code"
    t.string   "typeofuser"
    t.integer  "user_id"
    t.string   "designation"
    t.string   "department"
    t.string   "off_number"
    t.string   "mob_number"
    t.datetime "deactivated_at"
    t.integer  "tenant_id"
    t.boolean  "is_bounced",                               :default => false
    t.integer  "group_id",                                 :default => 1
    t.integer  "no_of_courses_assigned",                   :default => 0
    t.integer  "no_of_assessments_assigned",               :default => 0
    t.integer  "completed",                                :default => 0
    t.integer  "incomplete",                               :default => 0
    t.integer  "unattempted",                              :default => 0
    t.integer  "timeup",                                   :default => 0
    t.string   "type_of_evaluator"
    t.string   "address"
    t.string   "date_of_birth"
    t.string   "alternate_email"
    t.string   "student_course"
    t.string   "student_course_year"
    t.string   "student_college"
    t.string   "student_college_city"
    t.string   "bugz_profile_file_name"
    t.string   "bugz_profile_content_type"
    t.integer  "bugz_profile_file_size"
  end

  add_index "users", ["activation_code"], :name => "usr_activation_code_index"
  add_index "users", ["crypted_password"], :name => "usr_crypted_password_index"
  add_index "users", ["deactivated_at"], :name => "usr_deactiavted_at_index"
  add_index "users", ["email"], :name => "usr_email_index"
  add_index "users", ["group_id"], :name => "usr_group_id_index"
  add_index "users", ["reset_code"], :name => "usr_reset_code_index"
  add_index "users", ["user_id"], :name => "usr_user_id_index"

  create_table "widgets", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "div_name"
  end

end
