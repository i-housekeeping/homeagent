class CreateBanks < ActiveRecord::Migration
  def self.up
    create_table :banks do |t|
    t.string    "name",         :limit => 20
    t.string    "branch",       :limit => 20
    t.string    "address"
    t.string    "city",         :limit => 20
    t.string    "country",      :limit => 45
    t.string    "phone",        :limit => 45
    t.string    "fax",          :limit => 45
    t.string    "email",        :limit => 45
    t.string    "url",          :limit => 45
    t.string    "conn_person",  :limit => 45
    t.string    "businessdate", :limit => 20
    t.string    "record_sts",   :limit => 4,  :default => "ACTV"
    t.timestamp "last_update"
    end
  end

  def self.down
    drop_table :banks
  end
end
