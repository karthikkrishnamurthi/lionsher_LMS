class CreateTableAssessmentsQuestionBanks < ActiveRecord::Migration
  def self.up
    create_table :assessments_question_banks do |t|
      t.integer :assessment_id
      t.integer :question_bank_id
      t.integer :limit
      t.timestamps
    end
  end

  def self.down
  end
end
