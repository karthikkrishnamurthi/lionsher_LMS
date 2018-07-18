class AddHasImageToQuestions < ActiveRecord::Migration
  def self.up
    add_column  :questions, :has_image, :string
  end

  def self.down
  end
end
