class ChangeColumnMultiTopicToNoOfSections < ActiveRecord::Migration
  def self.up
    rename_column :test_patterns, :multi_topic, :no_of_sections
    change_column :test_patterns, :no_of_sections, :integer, :default => 1
  end

  def self.down
  end
end
