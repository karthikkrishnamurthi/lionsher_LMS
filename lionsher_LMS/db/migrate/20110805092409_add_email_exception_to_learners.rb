class AddEmailExceptionToLearners < ActiveRecord::Migration
  def self.up
    add_column :learners ,  :email_exception,  :text
  end

  def self.down
  end
end
