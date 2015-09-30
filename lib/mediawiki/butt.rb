require_relative 'auth'
require_relative 'query'
require_relative 'constants'
require_relative 'edit'
require 'httpclient'
require 'json'

module MediaWiki
  class Butt
    include MediaWiki::Auth
    include MediaWiki::Query::Meta
    include MediaWiki::Query::Properties
    include MediaWiki::Query::Lists
    include MediaWiki::Constants::Namespaces
    include MediaWiki::Edit

    # Creates a new instance of MediaWiki::Butt. To work with any MediaWiki::Butt methods, you must first create an instance of it.
    #
    # @param url [String] The FULL wiki URL. api.php can be omitted, but it will make harsh assumptions about your wiki configuration.
    # @param use_ssl [Boolean] Whether or not to use SSL. Will default to true.
    # @return [MediaWiki::Butt] new instance of MediaWiki::Butt
    def initialize(url, use_ssl = true)
      if url =~ /api.php$/
        @url = url
      else
        @url = "#{url}/api.php"
      end

      @client = HTTPClient.new
      @uri = URI.parse(@url)
      @ssl = use_ssl
      @logged_in = false
      @tokens = {}
    end

    # Performs a generic HTTP POST action and provides the response. This method generally should not be used by the user, unless there is not a method provided by the Butt developers for a particular action.
    #
    # @param params [Hash] A basic hash containing MediaWiki API parameters. Please see the MediaWiki API for more information.
    # @param autoparse [Boolean] Whether or not to provide a parsed version of the response's JSON. Will default to true.
    # @param header [Hash] The header hash. Optional.
    # @return [JSON/HTTPMessage] Parsed JSON if autoparse is true, or raw response if not.
    def post(params, autoparse = true, header = nil)
      if header == nil
        response = @client.post(@uri, params)
      else
        response = @client.post(@uri, params, header)
      end

      if autoparse == true
        return JSON.parse(response.body)
      else
        return response
      end
    end

    # Returns true if the currently logged in user is in the "bot" group. This can be helpful to some developers, but it is mostly for use internally in MediaWiki::Butt.
    # @return [Boolean] true if logged in as a bot, false if not logged in or logged in as a non-bot
    def is_current_user_bot?
      if @logged_in == true
        groups = get_usergroups
        if groups.include? "bot"
          return true
        else
          return false
        end
      else
        return false
      end
    end
  end
end
