require 'net/http'
require 'json'
require 'digest'
require 'uri'

module WHUSBSDK
  class Client
    def initialize(api_key: nil, api_secret: nil, base_url: nil)
      @api_key = api_key
      @api_secret = api_secret
      @base_url = (base_url || ENV['WHUSB_API_BASE_URL'] || "https://api.whu.sb/api/v1").chomp('/')
    end

    def search_courses(query, page: 1, limit: 12)
      request(:get, 'search/courses', query: { query: query, page: page, limit: limit })
    end

    def list_courses(page: 1, limit: 20)
      request(:get, 'courses', query: { page: page, limit: limit })
    end

    def get_me
      request(:get, 'users/me')
    end

    def translate(text, target)
      request(:post, 'translation/translate', body: { text: text, target: target })
    end

    private

    def generate_signature(timestamp)
      return "" if @api_key.nil? || @api_secret.nil?
      payload = "#{@api_key}#{timestamp}#{@api_secret}"
      Digest::SHA256.hexdigest(payload)
    end

    def request(method, endpoint, query: {}, body: nil)
      uri = URI("#{@base_url}/#{endpoint.sub(/^\//, '')}")
      uri.query = URI.encode_www_form(query) unless query.empty?

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      case method
      when :get
        req = Net::HTTP::Get.new(uri)
      when :post
        req = Net::HTTP::Post.new(uri)
      when :put
        req = Net::HTTP::Put.new(uri)
      when :delete
        req = Net::HTTP::Delete.new(uri)
      end

      timestamp = Time.now.to_i
      req['Content-Type'] = 'application/json'
      req['X-API-Key'] = @api_key || ""
      req['X-Timestamp'] = timestamp.to_string rescue timestamp.to_s

      if @api_secret
        req['X-Signature'] = generate_signature(timestamp)
      end

      req.body = body.to_json if body

      response = http.request(req)
      result = JSON.parse(response.body)

      unless response.is_a?(Net::HTTPSuccess) && result['success']
        raise "API Request Failed (#{response.code}): #{result['message']}"
      end

      result['data']
    end
  end
end
