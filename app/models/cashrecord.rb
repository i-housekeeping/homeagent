class Cashrecord < ActiveRecord::Base
  belongs_to :account
  belongs_to :customer
  belongs_to :category
  has_many :stories, :as=>:storiable
end
