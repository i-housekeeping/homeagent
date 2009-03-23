class Task < ActiveRecord::Base
  has_and_belongs_to_many :tasklists
  has_many :cashrecords
  
  before_save :format_data
  
  def format_data
    self.dueDate = Date.strptime(dueDate, '%Y-%m-%dT%H:%M:%S').strftime('%m-%d-%Y %H:%M:%S').to_s
  end
end
