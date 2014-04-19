class CreateContents < ActiveRecord::Migration
  def change
    if !table_exists? :contents
      create_table :contents do |table|
        table.column :title, :string
        table.column :created_at, :datetime
        table.column :url, :string
        table.column :author, :string
        table.column :cover, :string
        table.column :description, :text
        table.column :content, :text
        table.column :source, :string
        table.column :published, :boolean
      end
    end
    add_index(:contents, :url, :unique => true) if !index_exists?(:contents, :url, :unique => true)
  end
end
