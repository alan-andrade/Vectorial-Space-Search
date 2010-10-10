class Cluster < ActiveRecord::Base
  has_many  :cluster_docs
  has_many  :docs, :through =>  :cluster_docs
  
  ##
  # Self Referential logic
  ##
  
  has_many  :parent_of, :foreign_key  =>  'parent_id',
                        :class_name   =>  'ClusterJoin'
  has_many  :childs   , :through      =>  :parent_of                      
  
  has_many  :son_of   , :foreign_key  =>  'child_id',
                        :class_name   =>  'ClusterJoin'
  has_one   :parent   , :through      =>  :son_of                      
end
