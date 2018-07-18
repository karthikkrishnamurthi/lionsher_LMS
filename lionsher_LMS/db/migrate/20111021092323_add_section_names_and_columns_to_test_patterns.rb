class AddSectionNamesAndColumnsToTestPatterns < ActiveRecord::Migration
  def self.up
    add_column :test_patterns, :section_names, :string
    add_column :test_patterns, :questions_per_section, :string
    add_column :test_patterns, :duration_per_section, :string
    add_column :test_patterns, :total_duration, :integer, :default => 0
  end

  def self.down
  end
end
