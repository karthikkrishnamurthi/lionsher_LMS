class AddMtfIdToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :mtf_id, :integer
  end

  def self.down
  end
end
