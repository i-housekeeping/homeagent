class Account < ActiveRecord::Base
  has_and_belongs_to_many :banks 
  belongs_to :contact
  has_many :cashrecords
  has_many :notes, :through=>:cashrecords
  
  def text
      "Account : #{read_attribute(:account_no)}" 
  end
  
  def description
      "Account : #{read_attribute(:account_no)}" 
  end
end
