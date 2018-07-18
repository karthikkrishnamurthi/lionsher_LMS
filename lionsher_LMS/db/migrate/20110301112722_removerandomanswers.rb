class Removerandomanswers < ActiveRecord::Migration
  def self.up
    remove_column :assessments, :random_answers
  end

  def self.down
  end
end
