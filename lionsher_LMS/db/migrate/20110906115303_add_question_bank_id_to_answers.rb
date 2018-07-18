class AddQuestionBankIdToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers , :question_bank_id, :integer
  end

  def self.down
  end
end
