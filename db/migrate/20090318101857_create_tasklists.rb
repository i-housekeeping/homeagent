class CreateTasklists < ActiveRecord::Migration
  def self.up
    create_table :tasklists do |t|    
      t.integer   "parent_id"
      t.integer   "lft"
      t.integer   "rgt"
      t.string    "text" #list Name
      t.integer   "user_id"
      t.string    "description"
      t.string    "record_sts",   :limit => 4,  :default => "ACTV"
      t.timestamp "last_update" 
      t.string    "fprint"
      t.timestamps
    end
  end

  def self.down
    drop_table :tasklists
  end
end
