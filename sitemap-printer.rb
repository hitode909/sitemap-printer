Bundler.require

require 'logger'

LOG = Logger.new(STDERR)

if ENV['SITEMAP_PRINTER_DEBUG']
  LOG.level = Logger::DEBUG
else
  LOG.level = Logger::INFO
end

class SiteMap
  def uris sitemap_uri
    Enumerator.new{ |yielder|
      index = Nokogiri get sitemap_uri
      index.search('sitemap loc').each{|loc|
        uris(loc.content).each {|uri|
          yielder << uri
        }
      }
      index.search('url loc').each{|loc|
        uri = loc.content
        yielder << uri
      }
    }
  end

  protected

  def get uri
    LOG.debug "get #{uri}"
    RestClient.get(uri, :user_agent => "sitemap-printer")
  end
end

sitemap_uri = ARGV.first

unless sitemap_uri
  warn "usage: bundle exec -- ruby sitemap-printer.rb SITEMAP_XML_URI"
  exit 1
end

sitemap = SiteMap.new

uris = sitemap.uris(sitemap_uri)
uris.each{|uri|
  puts uri
}
