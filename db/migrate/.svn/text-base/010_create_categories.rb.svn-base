class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
    t.integer   "parent_id"
    t.integer   "lft"
    t.integer   "rgt"
    t.string    "text"
    t.integer   "code"
    t.string    "category_type"
    t.string    "description"
    t.string    "record_sts",   :limit => 4,  :default => "ACTV"
    t.timestamp "last_update" 
    t.string    "fprint"
    end
  end

  def self.down
    drop_table :categories
  end
end
