class Collaborate < ActiveRecord::Base
  belongs_to :user
  has_many :notes, :as=>:notable
end
