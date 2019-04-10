require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/custom_logger'
require 'logger'
require './scraper'
require './models'

set :database, { adapter: "sqlite3", database: "scraper.sqlite3" }

class App < Sinatra::Base
	register Sinatra::ActiveRecordExtension
	helpers Sinatra::CustomLogger

	configure :development, :production do
		logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
		logger.level = Logger::DEBUG if development?
		set :logger, logger
	end

	post '/stories' do
		url = params[:url]
		logger.info "url: #{url}"
		if url =~ /^https?:\/\// # basic check of valid URL
			Scraper.crawl_url(url) do |success, body|
				if success
					canonical_url = Scraper.get_canonical_url(body) || url
					story = Story.where(canonical_url: canonical_url).take

					if !story || story&.scrape_status == Story::STATUS_ERROR
						opengraph_tags = Scraper.get_opengraph_tags(body)
						scrape_status = Story::STATUS_DONE

						story = Story.create(
							canonical_url: canonical_url,
							scrape_status: scrape_status,
							ogp_tags: opengraph_tags
						)
					end
					json({
						id: story.id
					})
				else
					story = Story.create(
						canonical_url: url,
						scrape_status: Story::STATUS_ERROR,
						ogp_tags: nil
					)
					json({
						error: "Scrape error"
					})
				end
			end
		else
			json({
				error: "Invalid url format"
			})
		end
	end

	get '/stories/:canonical_url_id' do
		logger.info "canonical_url_id: #{params[:canonical_url_id]}"
		begin
			scrape_info = get_story(params[:canonical_url_id])
			json(scrape_info)		
		rescue ActiveRecord::RecordNotFound => e
			json({
				error: "Not found by canonical_url_id"
			})			
		end
	end
end

def get_story(canonical_url_id)
	story = Story.find(canonical_url_id)
	scrape_info = story.ogp_tags || {}
	scrape_info[:id] = story.id
	scrape_info[:updated_time] = story.updated_at
	scrape_info[:scrape_status] = story.get_scrape_status
	scrape_info[:url] ||= story.canonical_url
	scrape_info
end
