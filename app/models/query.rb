class Query < CommonActionsObject
  set_table_name :queries
  attr_accessor :content
  belongs_to    :term
  
  def save_query
    terms_definition
  end
    
  def self.query(queryid=1, metodo)
    case metodo
      when 'tfidf'
        find_by_sql(  "select i.doc_id docid, sum(q.tf * t.idf * i.tf * t.idf) weight from queries q, doc_terms i, terms t where q.query_id = #{queryid} AND q.term_id = t.id AND i.term_id = t.id group by i.doc_id order by 2 desc")
      when 'coseno'
        find_by_sql(  "select i.doc_id docid, sum(q.tf * t.idf * i.tf * t.idf) / (dw.weight * qw.weight) weight
                      from queries q, doc_terms i, terms t, docs_weights dw, query_weights qw
                      where q.query_id = #{queryid} AND
                      q.term_id = t.id AND
                      i.term_id = t.id AND
                      i.doc_id = dw.doc_id
                      group by i.doc_id, dw.weight, qw.weight
                      order by 2 desc")
    end
  end
end
