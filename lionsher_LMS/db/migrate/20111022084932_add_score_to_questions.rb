class AddScoreToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :score, :float, :default=>1
  end

  def self.down
  end
end
