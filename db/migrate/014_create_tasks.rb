class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string    "taskId",          :limit => 10
      t.string    "title",           :limit => 45
      t.text      "description"
      t.string    "dueDate",         :limit => 25
      t.boolean   "completed"
      t.string    "completedDate",   :limit => 25
      t.string    "reminder",        :limit => 25
      t.string    "record_sts",      :limit => 4,  :default => "ACTV"
      t.timestamp "last_update"
    end
  end
  
  def self.down
    drop_table :tasks
  end
end
