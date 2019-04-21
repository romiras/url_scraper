class ScraperQueue
	@queue = :scraper_job

	def self.perform(url)
		scraper_job = ScraperJob.find_by(url: url)
		scraper_job.update!(scrape_status: ScraperJob::STATUS_PENDING)

		Scraper.crawl_url(url) do |success, body|
			if success
				canonical_url = Scraper.get_canonical_url(body) || url
				story = scraper_job.story

				if !story || scraper_job&.scrape_status == ScraperJob::STATUS_ERROR
					opengraph_tags = Scraper.get_opengraph_tags(body)
					story = Story.create!(
						canonical_url: canonical_url,
						ogp_tags: opengraph_tags
					)
					scraper_job.update!(
						story_id: story.id,
						scrape_status: ScraperJob::STATUS_DONE
					)
				end
			else
				scraper_job.update!(scrape_status: ScraperJob::STATUS_ERROR)
			end
		end
	end
end

