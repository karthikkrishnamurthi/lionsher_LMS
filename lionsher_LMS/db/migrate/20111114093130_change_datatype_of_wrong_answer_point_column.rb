class ChangeDatatypeOfWrongAnswerPointColumn < ActiveRecord::Migration
  def self.up
    change_column :assessments, :wrong_ans_points, :float
  end

  def self.down
  end
end
