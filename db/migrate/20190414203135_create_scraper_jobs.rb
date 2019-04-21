class CreateScraperJobs < ActiveRecord::Migration[5.2]
	def up
		create_table :scraper_jobs do |t|
			t.string :url, null: false
			t.integer :story_id
			t.integer :scrape_status, null: false, default: 0
			t.datetime :created_at
			t.datetime :updated_at
		end

		Story.find_in_batches do |stories|
			ScraperJob.transaction do
				stories.each do |story|
					ScraperJob.create!(
						story_id: story.id,
						url: story.canonical_url,
						scrape_status: story.scrape_status
					)      		
				end
			end
		end

		add_index :scraper_jobs, :url, unique: true

		remove_column :stories, :scrape_status
	end

	def down
		# TODO:
		# revert deleted columns
		# update values of deleted columns
		# delete table :scraper_jobs
	end
end
