class BankAccounts < ActiveRecord::Migration
  def self.up
    create_table :banks_accounts, :id => false, :force => true do |t|
      t.integer "bank_id"
      t.integer "account_id"
    end
  end

  def self.down
    drop_table :banks_accounts
  end
end
