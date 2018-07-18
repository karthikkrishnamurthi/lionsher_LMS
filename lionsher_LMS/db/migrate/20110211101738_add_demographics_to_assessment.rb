class AddDemographicsToAssessment < ActiveRecord::Migration
  def self.up
    add_column :assessments, :take_demographic_information, :string, :default => "off"
    add_column :assessments, :instruction_for_test, :text
  end

  def self.down
  end
end
