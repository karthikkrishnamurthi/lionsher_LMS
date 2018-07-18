class AddTagvalueIdToQuestionAttributes < ActiveRecord::Migration
  def self.up
    add_column :question_attributes, :tagvalue_id, :integer
  end

  def self.down
  end
end
