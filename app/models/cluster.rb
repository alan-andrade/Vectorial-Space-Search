class Cluster < ActiveRecord::Base
  ##
  # Documents in one cluster logic
  ##
  
  has_many  :cluster_docs,  :dependent  =>  :destroy
  has_many  :docs,          :through    =>  :cluster_docs
  
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
  
  ###
  # Clustrize Implementation
  ###
  def self.clusterize
    ##
    # One cluster per Document
    ##
    Doc.all.each{|document| (Cluster.create.docs << document) unless document.cluster }
    
    ###
    # Using Complete Binding. The min of similarities 
    ###
    similarity_matrix = SimilarityMatrix.find :all, 
                                              :conditions => ["similarity > ?" , 0], 
                                              :order      => 'similarity'
    ###
    # Use the order from similarity_matrix. From the min to max, we start to cluster.
    # !! EXPERIMENTAL !!
    ###
    
    for similarity in similarity_matrix
      first_doc_id  = similarity.x
      second_doc_id = similarity.y
      join_from_docs(first_doc_id,  second_doc_id)      
      #similarity.destroy
    end
    
    ##
    # Finally, Calculate the centroid of each Cluster
    ## 
    
    
    
  end
  
  private
  
  def self.join_from_docs(first_doc_id,second_doc_id)
    first_document  = Doc.find(first_doc_id,  :include  =>  :cluster)
    first_cluster   = first_document.cluster
    
    second_document = Doc.find(second_doc_id, :include  =>  :cluster)    
    second_cluster  = second_document.cluster
    
    join_from_clusters(first_cluster, second_cluster)
  end
  
  def self.join_from_clusters(first_cluster, second_cluster)
    first_cluster_documents   = first_cluster.docs.count
    second_cluster_documents  = second_cluster.docs.count
    
    if first_cluster_documents == 1 and second_cluster_documents == 1
      ##
      # Soft Join: Join the document INTO one cluster.
      ##
      first_cluster.docs << second_cluster.docs
      second_cluster.destroy
    else
      ##
      # Hard Join: Join clusters into Clusters.
      ##    
      Cluster.create.childs << first_cluster << second_cluster
    end
  end
end
