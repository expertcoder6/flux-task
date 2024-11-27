class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :link
      t.references :request

      t.timestamps
    end
  end
end
