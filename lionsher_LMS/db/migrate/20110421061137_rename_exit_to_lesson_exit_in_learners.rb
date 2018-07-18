class RenameExitToLessonExitInLearners < ActiveRecord::Migration
  def self.up
    rename_column :learners, :exit, :lesson_exit
  end

  def self.down
  end
end
