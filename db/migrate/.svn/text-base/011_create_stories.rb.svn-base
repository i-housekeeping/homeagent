class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
    t.string    "title"
    t.text      "story"
    t.string    "user"
    t.string    "story_type"
    t.string    "last_update"
    t.string    "record_sts",   :limit => 4,  :default => "ACTV"
    t.references :storiable, :polymorphic => true
    end
  end

  def self.down
    drop_table :stories
  end
end
