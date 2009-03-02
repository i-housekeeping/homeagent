class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string    :title
      t.string    :domain,        :limit => 20
      t.string    :description
      t.string    :domain_description
      t.string    :record_sts,  :limit => 4,  :default => "ACTV"
      t.timestamp :last_update
    end
  end
  
  def self.down
    drop_table :roles
  end
end
