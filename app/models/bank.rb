class Bank < ActiveRecord::Base
  has_and_belongs_to_many  :accounts
  has_many :contacts, :through=>:accounts
end
