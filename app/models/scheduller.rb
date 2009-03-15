class Scheduller < ActiveRecord::Base
  has_many :triggers
  belongs_to :user
end
