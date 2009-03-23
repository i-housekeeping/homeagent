class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :notable, :polymorphic => true
  
  def create_note(note_owner, current_user)
    self.title = "Create #{note_owner.text}"
    self.note = "New note created for #{note_owner.description} successfully. Start the blogging without any furhter problems."
    self.notable = note_owner
    self.last_update = DateTime::now().strftime("%B %d, %Y %I:%M%p")
    self.user = current_user.login
    self.note_type = 'AUDIT'
    self.save
  end
  
  def create_cashnote(note_owner, current_user)
    self.title = "Create New Cashrecord"
    self.note = "Created cashrecord with DR #{note_owner.debit_amount.to_s} and CR #{note_owner.credit_amount.to_s} for #{note_owner.balance_date} with reference #{note_owner.reference}"
    self.notable = note_owner
    self.last_update = DateTime::now().strftime("%B %d, %Y %I:%M%p")
    self.user = current_user.login
    self.note_type = 'AUDIT'
    self.save
  end
  
  def update_note(note_owner, current_user, note)
    self.title = "Update #{note_owner.text}"
    self.note = note
    self.notable = note_owner
    self.last_update = DateTime::now().strftime("%B %d, %Y %I:%M%p")
    self.user = current_user.login
    self.note_type = 'AUDIT'
    self.save
  end
  
  def delete_note(note_owner, current_user)
    self.title = "Deleted #{note_owner.text}"
    self.note = "note created for #{note_owner.description} successfully."
    self.notable = note_owner
    self.last_update = DateTime::now().strftime("%B %d, %Y %I:%M%p")
    self.user = current_user.login
    self.note_type = 'AUDIT'
    self.save
  end
end
