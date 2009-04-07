class Task < ActiveRecord::Base
  has_and_belongs_to_many :tasklists
  has_many :cashrecords
  has_many :collaborates
  has_many :notes, :as=>:notable
  
  #before_save :format_dates
  before_update :format_dates
  
  def format_dates
    self.dueDate = Date.strptime(dueDate, '%Y-%m-%dT%H:%M:%S').strftime('%m-%d-%Y %H:%M:%S').to_s   
    self.completedDate = completedDate.empty? ? "" : Date.strptime(completedDate, '%Y-%m-%dT%H:%M:%S').strftime('%m-%d-%Y %H:%M:%S').to_s
    self.reminder = reminder.empty? ? "" : Date.strptime(reminder, '%Y-%m-%dT%H:%M:%S').strftime('%m-%d-%Y %H:%M:%S').to_s   
  end
end
