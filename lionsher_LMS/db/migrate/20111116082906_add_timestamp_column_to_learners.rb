class AddTimestampColumnToLearners < ActiveRecord::Migration
  def self.up
    add_column :learners, :timestamps, :text
  end

  def self.down
  end
end
