class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string    "taskId",         :limit => 10
      t.string    "title",          :limit => 45
      t.string    "category",       :limit => 25
      t.text      "description"
      t.datetime  "dueDate"
      t.boolean   "completed"
      t.string    "record_sts",     :limit => 4,  :default => "ACTV"
      t.timestamp "last_update"
    end
  end
  
  def self.down
    drop_table :tasks
  end
end
