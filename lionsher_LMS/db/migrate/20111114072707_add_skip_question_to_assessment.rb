class AddSkipQuestionToAssessment < ActiveRecord::Migration
  def self.up
    remove_column :assessments, :qb_limit
    add_column :assessments, :skip_question, :boolean, :default => true
  end

  def self.down
  end
end
