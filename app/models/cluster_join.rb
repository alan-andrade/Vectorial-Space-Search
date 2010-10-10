class ClusterJoin < ActiveRecord::Base
  belongs_to  :parent,  :class_name => 'Cluster'
  belongs_to  :child,   :class_name => 'Cluster'
end
