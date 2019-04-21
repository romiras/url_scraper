require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/custom_logger'
require 'logger'
require './scraper'
require './models'
require './scraper_queue'

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
			scraper_job = ScraperJob.find_by(url: url)
			if !scraper_job
				logger.debug "--> !scraper_job"
				scraper_job = ScraperJob.create!(
					url: url,
					scrape_status: ScraperJob::STATUS_QUEUED
				)
				Resque.enqueue(ScraperQueue, url)
			elsif scraper_job.scrape_status == ScraperJob::STATUS_ERROR
				logger.debug "--> scraper_job.err"
				scraper_job.update!(scrape_status: ScraperJob::STATUS_QUEUED)
				Resque.enqueue(ScraperQueue, url)
			end
			json({
				id: scraper_job.id
			})
		else
			json({
				error: "Invalid url format"
			})
		end
	end

	get '/stories/:scraper_job_id' do
		logger.info "scraper_job_id: #{params[:scraper_job_id]}"
		begin
			scraper_job = ScraperJob.find(params[:scraper_job_id])
			if scraper_job.scrape_status == ScraperJob::STATUS_DONE
				story = scraper_job.story
				if story
					scrape_info = get_scrape_info(story)
					scrape_info[:scrape_status] = scraper_job.get_scrape_status
					json(scrape_info)
				else
					json({
						error: "Not processed yet"
					})
				end
			else
				json({
					error: "Not processed yet"
				})
			end
		rescue ActiveRecord::RecordNotFound => e
			json({
				error: "Not found by id"
			})
		end
	end
end


def get_scrape_info(story)
	scrape_info = story.ogp_tags || {}
	scrape_info[:id] = story.id
	scrape_info[:updated_time] = story.updated_at
	scrape_info[:url] ||= story.canonical_url
	scrape_info
end

