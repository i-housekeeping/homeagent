class CreateCollaborates < ActiveRecord::Migration
  def self.up
    create_table :collaborates do |t|
      t.integer   "user_id",      :limit => 10
      t.timestamps
    end
  end

  def self.down
    drop_table :collaborates
  end
end
