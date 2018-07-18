class AddColumnsToPulseSurvey < ActiveRecord::Migration
  def self.up
    add_column :pulse_surveys, :emp_id, :text
    add_column :pulse_surveys, :date_of_joining, :text
    add_column :pulse_surveys, :salary_grade, :text
    add_column :pulse_surveys, :function, :text
    add_column :pulse_surveys, :location, :text
  end

  def self.down
  end
end
