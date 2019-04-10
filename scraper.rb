require 'nokogiri'
module Scraper
	
	def self.crawl_url(url)
		response = Faraday.get(url)
		if response.status == 200
			yield(true, response.body)
		else
			# error
			yield(false, nil)
		end
	rescue Faraday::ClientError => ex
		# error
		yield(false, nil)
	end

	def self.get_canonical_url(body)
		doc = Nokogiri::HTML(body)
		elem = doc.at('link[rel="canonical"]')
		elem ? elem['href'] : nil
	end

	def self.get_opengraph_tags(body)
		og = OGP::OpenGraph.new(body)
		{
			url:   og.url,
			title: og.title,
			type:  og.type,
			image: og.images
		}
	rescue OGP::MissingAttributeError
		{}
	end
end
