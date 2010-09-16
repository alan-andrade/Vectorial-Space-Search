class QueryWeight < ActiveRecord::Base
  def self.fill
    connection.execute('insert into query_weights(weight) select sqrt(sum(q.tf * t.idf * q.tf *t.idf)) from queries q, terms t where q.term_id = t.id')
  end
end
