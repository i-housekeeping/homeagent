class Cashrecord < ActiveRecord::Base
  belongs_to :account
  belongs_to :customer
  belongs_to :task
  belongs_to :user
  has_many :notes, :as=>:notable
end
