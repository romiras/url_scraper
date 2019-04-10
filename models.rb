class Story < ActiveRecord::Base
	STATUS_PENDING = 0
	STATUS_DONE    = 1
	STATUS_ERROR   = 2

	validates :canonical_url, presence: true, uniqueness: true
	serialize :ogp_tags, JSON

	def get_scrape_status
		case scrape_status
		when STATUS_PENDING
			"pending"
		when STATUS_DONE
			"done"
		when STATUS_ERROR
			"error"
		end
	end
end
