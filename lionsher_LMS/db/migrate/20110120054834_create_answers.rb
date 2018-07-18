class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.integer :qid
      t.string :answer
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
