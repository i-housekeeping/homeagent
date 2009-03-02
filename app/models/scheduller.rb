class Scheduller < ActiveRecord::Base
  has_many :triggers
  has_many :tasks
  belongs_to :user
end
