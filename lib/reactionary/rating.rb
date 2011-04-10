require 'rubygems'
require 'json'

module Reactionary

  class Rating
    attr_accessor :comment_id, :creation_date, :name, :town_and_country, :vote_count, :your_comments
  
    def initialize(args)
      @comment_id = args[:comment_id].to_i
      @creation_date = args[:creation_date]
      @name = args[:name].strip
      @town_and_country = args[:town_and_country].strip
      @vote_count = args[:vote_count].to_i
      @your_comments = args[:your_comments].strip
    end
  
    def to_json(*a)
      {
        'ruby_class'        => self.class.name,
        'comment_id'        => @comment_id,
        'creation_date'     => @creation_date,
        'name'              => @name,
        'town_and_country'  => @town_and_country,
        'vote_count'        => @vote_count,
        'your_comments'     => @your_comments
      }.to_json(*a)
    end

  end

end