class ClusterDoc < ActiveRecord::Base
  belongs_to  :doc
  belongs_to  :cluster
end
