class DocsWeight < ActiveRecord::Base
  def self.fill
    connection.execute('insert into docs_weights(doc_id, weight) select doc_id, sqrt(sum(i.tf * t.idf * i.tf *t.idf)) weight from doc_terms i, terms t where i.term_id = t.id group by doc_id')
  end
end
