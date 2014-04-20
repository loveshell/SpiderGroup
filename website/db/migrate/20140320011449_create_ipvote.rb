class CreateIpvote < ActiveRecord::Migration
  def change
    if !table_exists? :ipvotes
      create_table :ipvotes do |table|
        table.column :user_id, :integer
        table.column :ip, :string
        table.column :vote, :integer
        table.column :created_at, :datetime
        table.column :content_id, :string
      end
    end

    add_index(:ipvotes, [:content_id, :user_id], :unique => true) if !index_exists?(:ipvotes, [:content_id, :user_id], :unique => true)
  end
end
