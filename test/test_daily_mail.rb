$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'test/unit'
require 'vcr'
require 'couch_potato'

require 'reactionary/daily_mail'
require 'reactionary/article'

CouchPotato::Config.database_name = 'reactionary-dev'

class TestDailyMail < Test::Unit::TestCase

  def setup
    @dailymail = Reactionary::DailyMail.new()
    
    VCR.config do |c|
      c.cassette_library_dir = 'fixtures/vcr_cassettes'
      c.stub_with :fakeweb # or :webmock
      c.ignore_hosts '127.0.0.1'
    end
    
  end

  def test_session_id
    VCR.use_cassette('session_id', :record => :new_episodes) do
      assert_match "54AEC09FC417825C727936431C5CBDE0", @dailymail.session_id
    end
  end

  def test_top_stories
    VCR.use_cassette('home_page', :record => :new_episodes) do
      links = @dailymail.top_stories
      assert_equal 23, links.size
    end
  end
  
  def test_article
    VCR.use_cassette('article-1356725', :record => :new_episodes) do
      article = @dailymail.article('/news/article-1356725/Newbury-horse-deaths-Investigators-remove-cable-racecourse.html')
      assert_equal 1356725, article.article_id
      assert_equal "Newbury horse deaths: Investigators remove cable from racecourse  | Mail Online", article.title
      assert_equal 'http://www.dailymail.co.uk/news/article-1356725/Newbury-horse-deaths-Investigators-remove-cable-racecourse.html', article.url
      assert_equal 'Two horses electrocuted at a racecourse are believed to have been killed by faulty underground cables punctured during maintenance work.', article.description
      assert_equal 'Newbury horse deaths Investigators remove cable racecourse', article.keywords
    end
  end
  
  def test_article_ratings
    VCR.use_cassette('article-1356657', :record => :new_episodes) do
      ratings = @dailymail.article_ratings('/news/article-1356657/The-great-clothes-bank-robbery-How-charities-lose-millions-Fagin-gangs.html', 10, "bestRated")
      assert_equal 10, ratings.size
      # assert_equal '{ "comment_id" => "4623420", "creation_date" => 1297672412000, "name" => "Toto Kubwa", "town_and_country" => "Cyprus", "vote_count" => 236, "your_comments" => "Nice van, wonder how they paid for it?" }', ratings[5]
    end
  end

  def test_save_article_and_ratings
    VCR.use_cassette('article-1356657', :record => :new_episodes) do
      ratings = @dailymail.article_ratings('/news/article-1356657/The-great-clothes-bank-robbery-How-charities-lose-millions-Fagin-gangs.html', 10, "bestRated")
      article = @dailymail.article('/news/article-1356657/The-great-clothes-bank-robbery-How-charities-lose-millions-Fagin-gangs.html')
      article.ratings = ratings
      puts article.inspect
      CouchPotato.database.save_document article # or save_document!      
      assert_equal true, false
    end
  end
  
  def test_parse_rating
    rating = 's0.commentId=4619476;s0.creationDate=new Date(1297641726000);s0.name="Jason Piers";s0.townAndCountry="London UK";s0.voteCount=393;s0.yourComments="This business isnt a penny business, last week the DM ran a story on the chap who sells the clothes donated to the salvation army making \u00A311m and the Sally Army making \u00A316M from it, hardly a two bob industry."; '
    json_rating = @dailymail.parse_rating(rating)
    # puts json_rating
  end
  
end
