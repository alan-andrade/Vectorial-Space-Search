class ClustersController < ApplicationController
  def create
    # Fill Similarity Matrix
    SimilarityMatrix.calculate_matrix
    
    # Recursively, separate into clusters.   
    Cluster.clusterize
    
  end
end
