class Cluster < ActiveRecord::Base
  ##
  # Documents in one cluster logic
  ##
  
  has_many  :cluster_docs,
            :dependent  =>  :destroy
  has_many  :docs,      
            :through    =>  :cluster_docs
  
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
    clean_tables    
    ##
    # One cluster per Document
    ##
    each_document_is_a_cluster        
    
    ###
    # Using Complete Binding. The min() of similarities 
    ###
    continue_clustering
    
    ##
    # Finally, Calculate the centroid of each Cluster
    ##   
    centroid_definition
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
  
  def self.clean_tables
    Cluster.delete_all
    ClusterDoc.delete_all
    ClusterJoin.delete_all
  end
  
  def self.each_document_is_a_cluster
    Doc.all.each{|document| Cluster.create.docs << document }
  end
  
  def self.continue_clustering
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
    end
  end
  
  def self.centroid_definition
    for cluster in Cluster.all
      values  = recursive_centroid(cluster)      
      tf  = values[:tf]
      n   = values[:n]
      cluster.centroid = tf/n
      cluster.save
    end
    'Done'
  end

  def self.recursive_centroid(cluster)    
    tf =  0.0
    n  =  0.0   
    cluster.childs.each do |child_cluster|
      hash  = recursive_centroid(child_cluster)
      tf    = hash[:tf]
      n     = hash[:n]
    end
    
    for doc in cluster.docs
      row = doc.tf_sum
      tf  += row.tf.to_f
      n   += row.n.to_f
    end
    {:tf  =>  tf, :n  =>  n}
  end
end
