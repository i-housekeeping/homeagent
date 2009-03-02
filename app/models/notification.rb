class Notification < ActiveRecord::Base
  belongs_to :user
  
  def reset_time
    self.last_update = Time.now
  end
end
