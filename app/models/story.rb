class Story < ActiveRecord::Base
  belongs_to :storiable, :polymorphic => true
  
  def create_story(story_owner, current_user)
    self.title = "Create #{story_owner.text}"
    self.story = "New Story created for #{story_owner.description} successfully. Start the blogging without any furhter problems."
    self.storiable = story_owner
    self.last_update = DateTime::now().strftime("%B %d, %Y %I:%M%p")
    self.user = current_user.login
    self.story_type = 'AUDIT'
    self.save
  end
  
  def create_cashstory(story_owner, current_user)
    self.title = "Create New Cashrecord"
    self.story = "Created cashrecord with DR #{story_owner.debit_amount.to_s} and CR #{story_owner.credit_amount.to_s} for #{story_owner.balance_date} with reference #{story_owner.reference}"
    self.storiable = story_owner
    self.last_update = DateTime::now().strftime("%B %d, %Y %I:%M%p")
    self.user = current_user.login
    self.story_type = 'AUDIT'
    self.save
  end
  
  def update_story(story_owner, current_user, story)
    self.title = "Update #{story_owner.text}"
    self.story = story
    self.storiable = story_owner
    self.last_update = DateTime::now().strftime("%B %d, %Y %I:%M%p")
    self.user = current_user.login
    self.story_type = 'AUDIT'
    self.save
  end
  
  def delete_story(story_owner, current_user)
    self.title = "Deleted #{story_owner.text}"
    self.story = "Story created for #{story_owner.description} successfully."
    self.storiable = story_owner
    self.last_update = DateTime::now().strftime("%B %d, %Y %I:%M%p")
    self.user = current_user.login
    self.story_type = 'AUDIT'
    self.save
  end
  
end
