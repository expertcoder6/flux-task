class CreateRequestResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :request_responses do |t|
      t.references :request, null: false, foreign_key: true
      t.string :image_url
      t.json :image_urls,default: []
      t.json :metadata

      t.timestamps
    end
  end
end
