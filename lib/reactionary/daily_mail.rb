require 'rubygems'
require 'mechanize'
require 'reactionary/article'
require 'reactionary/rating'
require 'reactionary/json_parse'

module Reactionary

  class DailyMail
  
    def initialize()
      @root_url = 'http://www.dailymail.co.uk'
      @agent = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }
      @session_id = nil
    end
  
    def session_id
      if @session_id.nil?
        get_session_id
      end
      @session_id
    end

    def top_stories
      links = ""
      @agent.get(@root_url) do |page|
        div = get_headline_div_id(page)
        links = page.parser.css("div##{div}-2 li a").map { |link| link['href'] }
        links.pop
      end
      links
    end

    def article(urn)
      the_page = ""
      @agent.get( @root_url + urn ) do |page|
        the_page = page
      end
      article_id = get_article_id(urn)
      description = get_metatag(the_page, 'description')
      keywords = get_metatag(the_page, 'keywords')
      Article.new(:title => the_page.title, 
                  :url => @root_url + urn, 
                  :article_id => article_id, 
                  :description => description,
                  :keywords => keywords
                  )
    end

    def article_ratings(urn, number_of_ratings, range)
      
      article_id = get_article_id(urn)
    
      page = @agent.post( @root_url + '/dwr/call/plaincall/AjaxReaderComments.getReaderCommentsCacheable5minutes.dwr', {
        "callCount" => "1",
        "page" => "#{urn}",
        "httpSessionId" => "",
        "scriptSessionId" => @session_id.to_s,
        "c0-scriptName" => "AjaxReaderComments",
        "c0-methodName" => "getReaderCommentsCacheable5minutes",
        "c0-id" => "0",
        "c0-param0" => "string:#{article_id.to_s}",
        "c0-param1" => "string:#{number_of_ratings.to_s}",
        "c0-param2" => "string:#{range}",
        "batchId" => "1"
      })

      ratings = page.body.split("\n")

      # skip the first 3 lines and the last one
      ratings = ratings[3..(number_of_ratings+2)]
      
      # remove variable declarations from first line
      ratings[0] = ratings[0].split(';', 11)[10]

      # put all our ratings in json
      ratings.collect { |rating| parse_rating(rating) }

    end

    def parse_rating(rating_string)
      # puts rating_string.to_s
      fields = rating_string.split(";", 6)
      comment_id = /s[\d]*\.commentId\=(\d*)/.match(fields[0])[1]
      creation_date = /s[\d]*\.creationDate\=new\sDate\((\d*)\)/.match(fields[1])[1]
      name = /s[\d]*\.name\=\"(.*)\"/.match(fields[2])[1]
      town_and_country = /s[\d]*\.townAndCountry\=\"(.*)\"/.match(fields[3])[1]
      vote_count = /s[\d]*\.voteCount\=(\d*)/.match(fields[4])[1]
      comments = /s[\d]*\.yourComments\=\"(.*)\".{2,3}$/.match(fields[5])[1]
      your_comments = JsonParse.json_parse(comments)
      Rating.new(:comment_id => comment_id,
                 :creation_date => creation_date,
                 :name => name,
                 :town_and_country => town_and_country,
                 :vote_count => vote_count,
                 :your_comments => your_comments
                 )
    end

    private

    # get a script session id
    def get_session_id
      @agent.get( @root_url +  '/dwr/engine.js') do |page|
        @session_id = extract_session_id(page.body)
      end
    end

    # http://www.soasta.com/findouthow/scripts/extract_a_SessionID.html
    def extract_session_id(body)
      dwrEngineJsBody = body
      prefix = 'dwr.engine._origScriptSessionId = "'
      startIndex = dwrEngineJsBody.index(prefix) + prefix.length
      endIndex = dwrEngineJsBody.index('"', startIndex + 1) - startIndex
      scriptSessionId = dwrEngineJsBody[startIndex, endIndex]
      scriptSessionId = scriptSessionId + ((rand * 1000).floor).to_s
      scriptSessionId
    end
  
    # find the ID of the top headlines element, which is in a script element that looks like this:
    # DM.has("r0c1p15", "headlines");
    def get_headline_div_id(page)
      script = page.parser.css('script').select { |script| script.text =~ /DM\.has\(\".*\"\,\ \"headlines\"\)/ }
      /DM\.has\(\"(.*)\"\,\ \"headlines\"\)/.match(script[0].to_s)[1]
    end
  
    # extract article id from the uri
    def get_article_id(urn)
      /\/news\/article\-(.*)\/.*/.match(urn)[1].to_i
    end
  
    # extract a meta tag value from the page
    def get_metatag(page, tag)
      page.parser.css("meta[name='#{tag}']").first['content']
    end  
  
  end
  
end