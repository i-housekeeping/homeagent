class Todolist < ActiveRecord::Migration
  def self.up
    create_table :tasklists_tasks, :id => false, :force => true do |t|
      t.integer "tasklist_id"
      t.integer "task_id"
    end
  end

  def self.down
    drop_table :tasklists_tasks
  end
end
