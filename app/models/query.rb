class Query < CommonActionsObject
  set_table_name :queries
  belongs_to    :term

  METHODS = {:point_product=>'Point Product', :coseno => "Coseno"}

  def save_query
    terms_definition
  end

  def self.query(query_id=1, metodo)
    # Since we render in our views the methods available in METHODS.
    self.send metodo, query_id
  end

  def self.query_with_feedback(query_id=1,iterations=1,metodo)
  
      # Retrieve the relevant documents ids from table Answers. // Educational Purpose.
      known_relevant_doc_ids  = Answer.find_all_by_query_id(query_id).map{|ans| ans.doc_id.to_s}

      #query_terms  = Query.find_all_by_query_id(query_id).map{|q| q.term } # palabras de la consulta
      query_terms_ids   = Query.get_query_terms(query_id, :id)

      # Make a normal Query.
      results           = Query.query(query_id, metodo)

      # Retrieve the relevant doc ids from the results.
      results_doc_ids   = results[:list].map{|doc| doc.docid}

      # Arreglos temporales para agregar los terminos a la tabla queries.
      temporal_terms_ids  , temporal_created_terms  =   {}  , []
      relevant_doc_ids    = []

      #start iterations
      iterations.to_i.times do
        
        # Get the first 5 relevant Documents ids
        relevant_doc_ids    = (results[:list].map(&:docid) & known_relevant_doc_ids)[0..5] 
        # Get the first 5 non-relevant Documents ids
        irrelevant_doc_ids  = (results_doc_ids - relevant_doc_ids)[0..5]

        # Now that we have the documents Ids, we retrieve the terms to be used.
        
        # Retrieve the most important term for EACH relevant document.
        relevant_terms_array  = Doc.find(relevant_doc_ids).map{|doc| Doc.most_important_term(doc.id) }
       
        # Retrieve the ID for each relevant document term.
        relevant_terms_ids    = relevant_terms_array.map{|rt| rt.term_id.to_i}

        # Retrieve the most important term for EACH non-relevant document
        irrelevant_terms_array  = Doc.find(irrelevant_doc_ids).map{|doc| Doc.most_important_term(doc.id)}

        # Retrieve the ID for each non-relevant document term.
        irrelevant_terms_ids    = irrelevant_terms_array.map{|it| it.term_id.to_i}

        # Finally we have the Q1 out from Q.
        new_query_terms_ids  = query_terms_ids + relevant_terms_ids  - irrelevant_terms_ids

        # Procedure to alter the Queries table, so that we can throw the query Again.
        until new_query_terms_ids.empty?
          for termid in new_query_terms_ids
            tf = new_query_terms_ids.count(termid)
            queryterm   = Query.find_by_query_id_and_term_id(query_id, termid)
            if queryterm.nil?
              queryterm = Query.create(:query_id=>query_id, :tf => tf, :term_id => termid)
              temporal_created_terms.push queryterm
            elsif queryterm.tf < tf
              temporal_terms_ids[termid.to_s.to_sym]=queryterm.tf
              queryterm.update_attribute 'tf', tf
            end
            new_query_terms_ids.delete(termid)
          end
        end

        # We throw the Query Again with Relevance Feedback Included.
        results  = Query.query(query_id, metodo)

      end   # Iterations Ends.

      # We remove the added terms to the Queries table by updating their TF to original state.
      temporal_terms_ids.each_pair do |id, tf|
        Query.find_by_query_id_and_term_id(query_id, id.to_s).update_attribute 'tf', tf
      end
      
      # Remove the terms created to achieve relevance feedback.
      temporal_created_terms.each{|query| query.delete }
      
      results
  end

  private


  def self.point_product(query_id=1)
    list = find_by_sql(  "select
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

    return {
      :list => list,
      :query_terms => Query.get_query_terms(query_id)
    }
  end

  def self.coseno(query_id=1)
    list  = find_by_sql(  "select
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
    {:list => list, :query_terms  =>  Query.get_query_terms(query_id)}
  end

  def self.get_query_terms(query_id=1, attr=:term)
    Term.find(Query.find_all_by_query_id(query_id).map{|q| q.term_id }).map{|t| eval("t.#{attr}")}
  end


end
