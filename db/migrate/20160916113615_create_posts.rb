class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :name, null: false
      t.references :user
      t.text :content, null: false, default: ''
      t.datetime :published_at, null: false
      t.integer :status, limit: 2, null: false, default: 0
      t.timestamps null: false
    end
    execute 'ALTER TABLE posts ALTER COLUMN published_at SET DEFAULT NOW()'
  end
end
