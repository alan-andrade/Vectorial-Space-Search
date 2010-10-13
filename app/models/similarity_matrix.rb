class SimilarityMatrix < ActiveRecord::Base
  def self.calculate_matrix    
    docs_quantity = Doc.count
    
    for first_index in 1..docs_quantity
      for second_index  in  first_index..docs_quantity
        first_doc_id  = first_index
        second_doc_id = second_index
        similarity    = docs_similarity(first_doc_id, second_doc_id).similarity || 0
        create        :x          =>    first_doc_id,
                      :y          =>    second_doc_id,
                      :similarity =>    similarity
      end
    end      
  end
  
  private
  
  ##
  # Method used to save time. 2 queries in 1. When similarity is nil, all row in nil.
  # TODO: Solve the problem of inserting nil row when is nil only the similarity
  ##
  def self.insert_docs_similarity(doc_id_1, doc_id_2)
    query   = "
               insert into 
                similarity_matrices(x, y, similarity)
               select 
                  dt1.doc_id, dt2.doc_id, sum(dt1.tf * t.idf * dt2.tf *t.idf) similarity 
               from 
                  doc_terms dt1, doc_terms dt2, terms t 
               where 
                  dt1.doc_id=#{doc_id_1}  AND 
                  dt2.doc_id=#{doc_id_2}  AND 
                  dt2.term_id=dt1.term_id AND 
                  dt1.term_id = t.id      AND 
                  dt2.term_id = t.id
              "    
    connection.execute(query)
  end
  
  ##
  # Method that queries the similarity between 2 documents.
  ##
  def self.docs_similarity(doc_id_1=1, doc_id_2=1)
    find_by_sql("
                  select 
                    sum(dt1.tf * t.idf * dt2.tf *t.idf) similarity 
                  from 
                    doc_terms dt1, doc_terms dt2, terms t 
                  where 
                    dt1.doc_id=#{doc_id_1}  AND 
                    dt2.doc_id=#{doc_id_2}  AND 
                    dt2.term_id=dt1.term_id AND 
                    dt1.term_id = t.id      AND 
                    dt2.term_id = t.id
                ")[0]
  end  
end
