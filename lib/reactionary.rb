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
  ratings = @dailymail.article_ratings(link, 10, "bestRated")
  puts "\tNumber of ratings: #{ratings.size}"
  article.ratings = ratings
  begin
    CouchPotato.database.save_document article # or save_document!
  rescue
    puts "Problem saving article: #{article.url}"
  end
end

