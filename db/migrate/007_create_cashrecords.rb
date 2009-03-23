class CreateCashrecords < ActiveRecord::Migration
  def self.up
    create_table :cashrecords do |t|
    t.integer   "user_id",      :limit => 10 
    t.integer   "task_id",      :limit => 10 
    t.string    "cashrec_type",    :limit => 20
    t.string    "reference",       :limit => 45
    t.integer   "dr_account_id",      :limit => 10
    t.float     "debit_amount",                  :default => 0.0 
    t.string    "dr_value_date",      :limit => 20
    t.integer   "cr_account_id",      :limit => 10
    t.float     "credit_amount",                 :default => 0.0
    t.string    "cr_value_date",      :limit => 20
    t.float     "original_balance",               :default => 0.0    
    t.string    "repetitive_type", :limit => 45
    t.integer   "record_sequence",      :limit => 10
    t.integer   "total_records",   :limit => 10, :null => false
    t.float     "repetitive_amount"
    t.string    "starting_date",      :limit => 20
    t.string    "details",         :limit => 250
    t.string    "cashrec_status",  :limit => 4,  :default => "ACTV"
    t.timestamp "last_update"
    end
  end

  def self.down
    drop_table :cashrecords
  end
end
