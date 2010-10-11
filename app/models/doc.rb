class Doc < CommonActionsObject
  set_table_name :docs

  has_many    :doc_terms
  has_many    :terms,   :through  =>  :doc_terms
  has_many    :cluster_docs
  has_one     :cluster, :through  =>  :cluster_docs
  after_save  :terms_definition  
  
  def self.most_important_term(id)
    find_by_sql("SELECT d.term_id term_id, t.term term, max(d.tf*t.idf) weight FROM doc_terms d, terms t where doc_id=#{id} AND t.id = d.term_id").first
  end
  
  def tf_sum
    Doc.find_by_sql("SELECT count(*) n, sum(dt.tf) tf FROM doc_terms dt where dt.doc_id = #{id}")[0]
  end

end
