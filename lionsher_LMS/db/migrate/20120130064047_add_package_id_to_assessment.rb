class AddPackageIdToAssessment < ActiveRecord::Migration
  def self.up
    add_column :assessments, :assessment_package_id, :integer
  end

  def self.down
  end
end
