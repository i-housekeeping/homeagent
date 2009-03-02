class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
    t.string    "customer_name", :limit => 45
    t.string    "customer_type", :limit => 45
    t.string    "address"
    t.string    "city",          :limit => 20
    t.string    "country",       :limit => 45
    t.string    "phone",         :limit => 45
    t.string    "fax",           :limit => 45
    t.string    "email",         :limit => 45
    t.string    "url",           :limit => 45
    t.string    "record_sts",    :limit => 4,  :default => "ACTV"
    t.timestamp "last_update"    end
  end

  def self.down
    drop_table :customers
  end
end
