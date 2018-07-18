class CreateProfileDetails < ActiveRecord::Migration
  def change
    create_table :profile_details do |t|
      t.integer :learner_id
      t.integer :profile_id
      t.string :value

      t.timestamps
    end
  end
end
