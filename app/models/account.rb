class Account < ActiveRecord::Base
  belongs_to :bank
  belongs_to :customer
  has_many :cashrecords
  has_many :stories, :as=>:storiable
  
  def text
      "Account : #{read_attribute(:account_no)}" 
  end
  
  def description
      "Account : #{read_attribute(:account_no)}" 
  end
end
