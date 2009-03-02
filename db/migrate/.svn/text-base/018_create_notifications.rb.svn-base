class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
    t.string    "notification_type",   :limit => 20
    t.text      "content"
    t.integer   "user_id",             :limit => 10
    t.string    "notification_status", :limit => 20
    t.string    "record_sts",          :limit => 4,  :default => "ACTV"
    t.timestamp "last_update"    
    end
  end

  def self.down
    drop_table :notifications
  end
end
