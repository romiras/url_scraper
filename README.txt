1.  Description
   1. Build a web service that will scrape  Open graph tags. For any given URL.
   2. See http://ogp.me/ for definitions
   3. See https://developers.facebook.com/tools/debug/sharing/?q=http%3A%2F%2Fogp.me%2F for an example implementation
2. Requirements
   The server should provide the following JSON API 
      1. Request
         1. POST api_host/stories?url={some_url}
      2. Response
         1. An ID representing the canonical URL of the given url (each canonical url should have a single matching id in the system) 
      3. Request
         1. GET api_host/stories/{canonical-url-id}
      4. Response
         1. scrape_status field can be (done,error,pending)
         2. {
              "url": "http://ogp.me/",
              "type": "website",
              "title": "Open Graph protocol",
              "image": [
              {
                "url": "http://ogp.me/logo.png",
                "type": "image/png",
                "width": 300,
                "height": 300,
                "alt": "The Open Graph logo"
              },
              ],
              "updated_time": "2018-02-18T03:41:09+0000",
	            "scrape_status": "done",
              "id": "10150237978467733"
          }
