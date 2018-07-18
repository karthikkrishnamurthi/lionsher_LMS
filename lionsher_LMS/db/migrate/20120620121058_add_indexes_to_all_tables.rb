class AddIndexesToAllTables < ActiveRecord::Migration
  def change
    add_index :answers, :question_id, :name => 'ans_question_id_index'
    add_index :answers, :question_bank_id, :name => 'ans_question_bank_id_index'

    add_index :assessment_questions, :assessment_id, :name => 'aq_assessment_id_index'
    add_index :assessment_questions, :question_id, :name => 'aq_question_id_index'

    add_index :assessments, :user_id, :name => 'as_user_id_index'

    add_index :assessments_question_banks, :assessment_id, :name => 'aqb_assessment_id_index'
    add_index :assessments_question_banks, :question_bank_id, :name => 'aqb_question_bank_id_index'

    add_index :coupons, :assessment_package_id, :name => 'cpn_assessment_package_id_index'

    add_index :courses, :user_id, :name => 'course_user_id_index'
    add_index :courses, :course_name, :name => 'course_name_index'

    add_index :descriptive_answers, :assessment_id, :name => 'da_assessment_id_index'
    add_index :descriptive_answers, :learner_id, :name => 'da_learner_id_index'
    add_index :descriptive_answers, :question_id, :name => 'da_question_id_index'
    add_index :descriptive_answers, :user_id, :name => 'da_user_id_index'

    add_index :emails, :email_type, :name => 'email_type_index'
    add_index :emails, :tenant_id, :name => 'email_tenant_id_index'

    add_index :groups, :group_name, :name => 'group_name_index'
    add_index :groups, :user_id, :name => 'group_user_id_index'

    add_index :learners, :active, :name => 'learner_active_index'
    add_index :learners, :admin_id, :name => 'learner_admin_id_index'
    add_index :learners, :assessment_id, :name => 'learner_assessment_id_index'
    add_index :learners, :course_id, :name => 'learner_course_id_index'
    add_index :learners, :group_id, :name => 'learner_group_id_index'
    add_index :learners, :lesson_status, :name => 'learner_lesson_status_index'
    add_index :learners, :tenant_id, :name => 'learner_tenant_id_index'
    add_index :learners, :type_of_test_taker, :name => 'learner_type_of_test_taker_index'
    add_index :learners, :user_id, :name => 'learner_user_id_index'

    add_index :question_banks, :user_id, :name => 'qb_user_id_index'

    add_index :questions, :mtf_id, :name => 'ques_mtf_id_index'
    add_index :questions, :question_bank_id, :name => 'ques_question_bank_id_index'

    add_index :tenants, :custom_url, :name => 'tenant_custom_url_index'
    add_index :tenants, :organization, :name => 'tenant_organization_index'
    add_index :tenants, :pricing_plan_id, :name => 'tenant_pricing_plan_id_index'
    add_index :tenants, :user_id, :name => 'tenant_user_id_index'

    add_index :transactions, :tenant_id, :name => 'transaction_tenant_id_index'

    add_index :users, :activation_code, :name => 'usr_activation_code_index'
    add_index :users, :crypted_password, :name => 'usr_crypted_password_index'
    add_index :users, :deactivated_at, :name => 'usr_deactiavted_at_index'
    add_index :users, :email, :name => 'usr_email_index'
    add_index :users, :group_id, :name => 'usr_group_id_index'
    add_index :users, :reset_code, :name => 'usr_reset_code_index'
    add_index :users, :user_id, :name => 'usr_user_id_index'
  end
end