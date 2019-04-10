class CreateStories < ActiveRecord::Migration[5.2]
  def change
    create_table :stories do |t|
      # t.string :url, null: false
      t.string :canonical_url, null: false
      t.integer :scrape_status, null: false, default: 0
      t.string :ogp_tags
      t.datetime :created_at
      t.datetime :updated_at
    end
    # add_index :stories, :url
    add_index :stories, :canonical_url, unique: true
  end
end
