class AddQuestionBankIdToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :qb_id, :integer
    add_column :questions, :question_type, :string
  end

  def self.down
  end
end
