class Query < CommonActionsObject
  set_table_name :queries
  attr_accessor :content
  belongs_to    :term
  
  def save_query
    terms_definition
  end
    
  def self.query(query_id=1, metodo)
    case metodo
      when 'tfidf'
        tfidf(query_id)
      when 'coseno'
        coseno(query_id)
    end
  end  
  
  private
  
  def self.tfidf(query_id=1)
    find_by_sql(  "select 
                      i.doc_id docid, sum(q.tf * t.idf * i.tf * t.idf) weight 
                   from 
                      queries q, doc_terms i, terms t 
                   where 
                      q.query_id = #{query_id} 
                      AND 
                        q.term_id = t.id 
                      AND 
                        i.term_id = t.id 
                   group by 
                      i.doc_id order by 2 desc")
  end
  
  def self.coseno(query_id=1)
    find_by_sql(  "select 
                      dt.doc_id docid, sum(q.tf * t.idf * dt.tf * t.idf) / (dw.weight * qw.weight) weight
                    from 
                      queries q, doc_terms dt, terms t, docs_weights dw, query_weights qw
                    where 
                      dt.term_id   = t.id
                    AND
                      q.query_id  = #{query_id} 
                    AND
                      dw.doc_id   = dt.doc_id
                    AND
                      q.term_id   = t.id
                    group by 
                      dt.doc_id, dw.weight, qw.weight
                    order by 
                      2 desc"  )    
  end
  

end
