class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
    t.integer   "parent_id"
    t.integer   "lft"
    t.integer   "rgt"
    t.string    "text"
    t.string    "name",          :limit => 45
    t.string    "description"
    t.integer   "alert_type_id",  :limit => 10
    t.integer   "alert_object_id",  :limit => 10
    t.integer   "priority",      :limit => 10
    t.string    "record_sts",   :limit => 4,  :default => "ACTV", :null => false
    t.timestamp "last_update"
    end
  end

  def self.down
    drop_table :alerts
  end
end
