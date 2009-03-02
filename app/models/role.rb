class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  validates_presence_of :title
  validates_uniqueness_of   :title, :case_sensitive => false
 
end
