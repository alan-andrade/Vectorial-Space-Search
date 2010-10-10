class Cluster < ActiveRecord::Base
  ##
  # Documents in one cluster logic
  ##
  
  has_many  :cluster_docs
  has_many  :docs, :through =>  :cluster_docs
  
  ##
  # Self Referential logic
  ##
  
  has_many  :parent_of, :foreign_key  =>  'parent_id',
                        :class_name   =>  'ClusterJoin',
                        :dependent    =>  :destroy
  has_many  :childs   , :through      =>  :parent_of                      
  
  has_many  :son_of   , :foreign_key  =>  'child_id',
                        :class_name   =>  'ClusterJoin',
                        :dependent    =>  :destroy
  has_one   :parent   , :through      =>  :son_of                      
  
  ##
  # clustrize Implementation
  ##
  def self.clusterize
    ##
    # One cluster per Document
    ##
    Doc.all.each{|document| Cluster.create.docs << document }
    
    ##
    # Using Unique Binding. The min of similarities 
    ##
    SimilarityMatrix.minimum('similarity', :conditions=>"similarity > 0")
  end
end
