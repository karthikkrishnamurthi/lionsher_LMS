class AddFewMoreImprovementRelatedColumns < ActiveRecord::Migration
  def self.up
    add_column  :assessments, :is_from_all_low_scoring, :boolean, :default => true
    add_column  :assessments, :no_of_less_scoring_sections, :integer, :default => 0
  end

  def self.down
  end
end
