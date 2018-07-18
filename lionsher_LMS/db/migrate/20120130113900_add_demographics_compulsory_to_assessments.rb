class AddDemographicsCompulsoryToAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments, :demographics_compulsory, :boolean, :default => false
  end

  def self.down
  end
end
