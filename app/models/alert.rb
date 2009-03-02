class Alert < ActiveRecord::Base
  has_many :alert_conditons
  has_many :alert_actions
  belongs_to :alert_object
  belongs_to :alert_type
  
  acts_as_nested_set :scope => "record_sts='ACTV'"
  
  def self.root_nodes
    find(:all, :conditions => "parent_id IS NULL and record_sts='ACTV'")
  end
  
  def self.find_children(start_id = nil)
    start_id.to_i == 0 ? root_nodes : find(start_id).direct_children
  end
  
  def leaf
    unknown? || children_count == 0
  end
  
  def to_json_with_leaf(options = {})
    self.to_json_without_leaf(options.merge(:methods => :leaf))
  end
  
  def activate (token)
    self.text = token
  end
  alias_method_chain :to_json, :leaf
end
