class CreateAssessmentComponents < ActiveRecord::Migration
  def change
    create_table :assessment_components do |t|
      t.string :name

      t.timestamps
    end
  end
end
