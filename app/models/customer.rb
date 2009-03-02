class Customer < ActiveRecord::Base
  has_many :accounts
  has_many :cashrecords, :through=>:accounts
  has_many :banks, :through=>:accounts
  has_many :categories, :through=>:cashrecords
  has_many :stories, :as=>:storiable
  
  def setAdobted (comapnyname)
    self.customer_name = comapnyname+ " : " + self.customer_name
    #TODO Submit the customer with a special status which later on could differentiate customers
    #self.record_sts = "ADPT"
  end
  
  
end
