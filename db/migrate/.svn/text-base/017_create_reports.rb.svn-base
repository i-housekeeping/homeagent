class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.string    "name",          :limit => 45
      t.string    "description"
      t.string    "report_type",   :limit => 20
      t.string    "template",      :limit => 45
      t.integer   "datasource_id", :limit => 10
      t.string    "protocol_name", :limit => 45
      t.string    "record_sts",    :limit => 4,  :default => "ACTV"
      t.timestamp "last_update"
    end
    
    create_table :reports_users, :id => false, :force => true do |t|
      t.column "reports_id", :integer
      t.column "user_id", :integer
    end
  end
  
  def self.down
    drop_table :reports
    drop_table :reports_users
  end
end
