class CreateAssessmentCourses < ActiveRecord::Migration
  def change
    create_table :assessment_courses do |t|
      t.integer :assessment_id
      t.integer :course_id
      t.integer :package_id
      t.integer :assessment_package_id
      t.integer :user_id
      t.integer :tenant_id

      t.timestamps
    end
  end
end
