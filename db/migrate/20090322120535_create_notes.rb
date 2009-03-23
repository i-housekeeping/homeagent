class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
    t.integer   "user_id",      :limit => 10
    t.string    "title"
    t.text      "note"
    t.string    "note_type"
    t.string    "last_update"
    t.string    "record_sts",   :limit => 4,  :default => "ACTV"
    t.references :notable, :polymorphic => true
    t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
