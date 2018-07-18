class AddDemographicIdToAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments, :demographics_id, :integer
  end

  def self.down
  end
end
