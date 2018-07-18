class CreateQuestionStatuses < ActiveRecord::Migration
  def change
    create_table :question_statuses do |t|
      t.string :status_value

      t.timestamps
    end
  end
end
