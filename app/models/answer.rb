class Answer < ActiveRecord::Base

  def self.fill_db(doc)
    file = File.open(doc)
    until file.eof? do
      if file.gets =~ /(\d*)\s(\d*)\s(\d*)\s(\d*)/
        doc_id    = $2 == '0' ? $3 : $2
        relevance = $4 == '' ? $3 : $4
        Answer.create(:query_id=>$1, :doc_id=> doc_id , :relevance=> relevance)
      end
    end
    true
  end
end
