class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
    t.integer   "contact_id",  :limit => 10
    t.string    "account_no",   :limit => 45
    t.string    "account_type", :limit => 20
    t.string    "currency",     :limit => 3
    t.float     "balance"
    t.string    "balance_date", :limit => 20
    t.float     "credit_limit"
    t.string    "record_sts",   :limit => 4,  :default => "ACTV", :null => false
    t.timestamp "last_update"
    end
  end

  def self.down
    drop_table :accounts
  end
end
