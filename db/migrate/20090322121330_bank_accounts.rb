class BankAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts_banks, :id => false, :force => true do |t|
      t.integer "bank_id"
      t.integer "account_id"
    end
  end

  def self.down
    drop_table :accounts_banks
  end
end
