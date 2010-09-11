class Answer < ActiveRecord::Base

  def self.fill_db(doc)
    file = File.open(doc)
    until file.eof? do
      if file.gets =~ /(\d*).(\d*).(\d*)/
        Answer.create(:query_id=>$1, :doc_id=>$2, :relevance=>$3)
      end
    end
  end
end
