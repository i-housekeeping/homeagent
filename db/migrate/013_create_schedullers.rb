class CreateSchedullers < ActiveRecord::Migration
  def self.up
    create_table :schedullers do |t|
    t.string    "name",           :limit => 45
    t.string    "description"
    t.string    "scheduller_time", :limit => 20, :default => "",     :null => false
    t.string    "record_sts",     :limit => 4,  :default => "ACTV"
    t.timestamp "last_update"
    end
  end

  def self.down
    drop_table :schedullers
  end
end
