class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :post
      t.references :user
      t.integer :parent_id, null: true, index: true
      t.integer :lft, null: false, index: true
      t.integer :rgt, null: false, index: true
      t.integer :depth, null: false, default: 0
      t.integer :children_countr, null: false, default: 0
      t.text :comment, null: false
      t.integer :status, limit: 2, null: false, default: 0
      t.timestamps null: false
    end
  end
end
