class ChangeAnswerTextColumnTypeToText < ActiveRecord::Migration
  def up
    change_column :answers, :answer, :text
  end

  def down
  end
end
