class Contact < ActiveRecord::Base
  has_many :accounts
  has_many :cashrecords
  has_many :banks, :through=>:accounts
  has_many :notes, :through=>:cashrecords
  has_many :tasks, :through=>:cashrecords
  
  def setAdobted (comapnyname)
    self.customer_name = comapnyname+ " : " + self.customer_name
    #TODO Submit the customer with a special status which later on could differentiate customers
    #self.record_sts = "ADPT"
  end
end
