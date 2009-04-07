class CreateCollaborates < ActiveRecord::Migration
  def self.up
    create_table :collaborates do |t|
      t.integer   "user_id",      :limit => 10
      t.integer   "task_id",      :limit => 10
      t.integer   "cashrecord_id",:limit => 10
      t.string    "link_to"
      t.string    "action_to"
      t.string    "auth_type"
      t.string    "login"
      t.string    "password"
      t.timestamps
    end
  end

  def self.down
    drop_table :collaborates
  end
end
