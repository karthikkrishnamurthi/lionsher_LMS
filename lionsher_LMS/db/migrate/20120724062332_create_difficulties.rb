class CreateDifficulties < ActiveRecord::Migration
  def change
    create_table :difficulties do |t|
      t.string :difficulty_value

      t.timestamps
    end
  end
end
