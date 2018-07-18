class ChangeColumnsInAssessments < ActiveRecord::Migration
  def self.up
    change_column :assessments, :am_pm, :string , :default => ""
    change_column :assessments, :show_status, :string, :default => "off"
    change_column :assessments, :show_score, :string, :default => "off"
    change_column :assessments, :send_score_by_mail, :string, :default => "off"
    change_column :assessments, :show_score_after_test, :string, :default => "off"
  end

  def self.down
  end
end
