class AddPackageIdToLearners < ActiveRecord::Migration
  def change
    add_column :learners, :package_id, :integer
  end
end
