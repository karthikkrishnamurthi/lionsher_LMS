class AddPassScoreToAssessments < ActiveRecord::Migration
  def self.up
    add_column  :assessments, :pass_score,  :string,  :default => ""
  end

  def self.down
  end
end
