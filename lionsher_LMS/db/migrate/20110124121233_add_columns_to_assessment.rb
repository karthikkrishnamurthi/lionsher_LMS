class AddColumnsToAssessment < ActiveRecord::Migration
  def self.up
    add_column :assessments, :am_pm, :string
    add_column :assessments, :show_status, :string, :default => "on"
    add_column :assessments, :show_score, :string, :default => "on"
    add_column :assessments, :send_score_by_mail, :string, :default => "on"
    add_column :assessments, :show_score_after_test, :string, :default => "on"
  end

  def self.down
  end
end
