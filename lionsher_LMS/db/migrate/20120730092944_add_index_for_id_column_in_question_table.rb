class AddIndexForIdColumnInQuestionTable < ActiveRecord::Migration
  def up
    add_index :questions, :id, :name => 'ques_id_index'
  end

  def down
  end
end
