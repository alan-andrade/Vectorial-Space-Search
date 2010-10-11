class ClustersController < ApplicationController
  def create
    # Fill Similarity Matrix
    SimilarityMatrix.calculate_matrix
    
    # Recursively, separate into clusters.   
    Cluster.clusterize
    
    flash[:notice]  = "Clustering Completed"
    redirect_to root_path
  end
end
