class Bank < ActiveRecord::Base
  has_many :accounts
  has_many :stories, :as=>:storiable
end
