class Log < ApplicationRecord

  include PgSearch
  pg_search_scope :search_by_title_and_body, :against => [:title],
    using: {
      :tsearch => {:prefix => true}
    }



  belongs_to :user
end
