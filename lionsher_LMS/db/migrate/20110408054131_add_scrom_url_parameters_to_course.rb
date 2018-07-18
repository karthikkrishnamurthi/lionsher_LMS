class AddScromUrlParametersToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :scorm_url_parameters, :string
  end

  def self.down
    remove_coulmn :courses, :scorm_url_parameters
  end
end
