$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'couch_potato'

require 'reactionary/daily_mail'
require 'reactionary/article'

CouchPotato::Config.database_name = "http://admin:password@127.0.0.1:5984/reactionary-test"

@dailymail = Reactionary::DailyMail.new()

puts @dailymail.session_id

links = @dailymail.top_stories
puts "Number of top stories: #{links.size}"

links.each do |link|
  puts "Link: #{link}"
  article = @dailymail.article(link)
  best_ratings = @dailymail.article_ratings(link, 10, "bestRated")
  puts "\tNumber of best ratings: #{best_ratings.size}"
  worst_ratings = @dailymail.article_ratings(link, 10, "worstRated")
  puts "\tNumber of worst ratings: #{worst_ratings.size}"
  article.ratings = best_ratings | worst_ratings
  puts "\tTotal number of ratings: #{article.ratings.size}"
  begin
    CouchPotato.database.save_document article # or save_document!
  rescue
    puts "Problem saving article: #{article.url}"
  end
end

