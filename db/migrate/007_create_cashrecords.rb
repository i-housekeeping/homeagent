class CreateCashrecords < ActiveRecord::Migration
  def self.up
    create_table :cashrecords do |t|
    t.string    "cid",             :limit => 20, :default => "",     :null => false
    t.integer   "account_id",      :limit => 10
    t.integer   "category_id",     :limit => 10
    t.integer   "customer_id",     :limit => 10
    t.string    "cashrec_type",    :limit => 20
    t.string    "cashrec_status",  :limit => 4,  :default => "ACTV"
    t.float     "debit_amount",                  :default => 0.0
    t.float     "credit_amount",                 :default => 0.0
    t.float     "current_balance",               :default => 0.0
    t.string    "currency",        :limit => 20
    t.string    "reference",       :limit => 45
    t.string    "value_date",      :limit => 20
    t.string    "balance_date",    :limit => 20
    t.string    "repetitive_type", :limit => 45
    t.integer   "record_seq",      :limit => 10
    t.integer   "total_records",   :limit => 10, :null => false
    t.float     "repetitive_amount"
    t.string    "starting_date",      :limit => 20
    t.string    "details",         :limit => 250
    t.timestamp "last_update"
    end
  end

  def self.down
    drop_table :cashrecords
  end
end
