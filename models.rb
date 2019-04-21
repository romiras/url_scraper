class Story < ActiveRecord::Base
	validates :canonical_url, presence: true, uniqueness: true
	serialize :ogp_tags, JSON
end

class ScraperJob < ActiveRecord::Base

	STATUS_PENDING = 0
	STATUS_DONE    = 1
	STATUS_ERROR   = 2
	STATUS_QUEUED  = 3

	belongs_to :story

	def get_scrape_status
		case scrape_status
		when STATUS_PENDING, STATUS_QUEUED
			"pending"
		when STATUS_DONE
			"done"
		when STATUS_ERROR
			"error"
		end
	end

end

