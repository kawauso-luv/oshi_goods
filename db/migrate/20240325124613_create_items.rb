class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :name
      t.string :description
      t.string :image_url
      t.integer :price
      t.string :category
      t.timestamps null: false
    end  
  end
end
