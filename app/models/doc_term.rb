class DocTerm < ActiveRecord::Base
  belongs_to :doc
  belongs_to :term  
end
