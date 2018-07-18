class AddQbLimitToAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments,:qb_limit,:string
  end

  def self.down
  end
end
