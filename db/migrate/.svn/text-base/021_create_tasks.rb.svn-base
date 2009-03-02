class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string    "name",           :limit => 45
      t.string    "description"
      t.integer   "scheduller_id",:limit => 10
      t.string    "url",            :limit => 45
      t.string    "interface_name", :limit => 45
      t.string    "record_sts",     :limit => 4,  :default => "ACTV"
      t.timestamp "last_update"
    end
  end
  
  def self.down
    drop_table :tasks
  end
end
