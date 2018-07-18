class AddActiveToLearners < ActiveRecord::Migration
  def self.up
     add_column :learners, :active, :string, :default => "yes"
  end

  def self.down
  end
end
