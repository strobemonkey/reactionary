require 'rubygems'
require 'couch_potato'

module Reactionary

  class Article

    include CouchPotato::Persistence

    property :title
    property :url
    property :article_id
    property :description
    property :keywords
    property :ratings
  
    view :all, :key => :_id
    
  end

end