class QueryWeight < ActiveRecord::Base
  def self.fill
    connection.execute('insert into query_weights(weight, query_id) select sqrt(sum(q.tf * t.idf * q.tf *t.idf)) weight, q.query_id from queries q, terms t where q.term_id = t.id group by q.query_id')
  end
end
