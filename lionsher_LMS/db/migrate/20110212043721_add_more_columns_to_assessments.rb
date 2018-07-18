class AddMoreColumnsToAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments, :take_name, :string, :default => "off"
    add_column :assessments, :take_age, :string, :default => "off"
    add_column :assessments, :take_gender, :string, :default => "off"
    add_column :assessments, :take_qualification, :string, :default => "off"
  end

  def self.down
  end
end
