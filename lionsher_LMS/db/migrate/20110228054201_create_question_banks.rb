class CreateQuestionBanks < ActiveRecord::Migration
  def self.up
    create_table :question_banks do |t|
      t.string :name
      t.integer :no_of_questions
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :question_banks
  end
end
