class Collaborate < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  belongs_to :cashrecord
  has_many :notes, :as=>:notable
end
