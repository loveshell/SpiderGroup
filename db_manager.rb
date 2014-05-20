require 'active_record'
require 'yaml'

class DBManager
  attr_accessor :sqlite3_dbfile

  def initialize(options)
    cfg = YAML::load(File.open(options[:dbconf]))
    if cfg[options[:env]]['adapter']=='sqlite3'
      @sqlite3_dbfile = "content.s3db"
      @sqlite3_dbfile = "./website/"+options[:dbfile]
      need_create = !File.exist?(@sqlite3_dbfile)
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database  => @sqlite3_dbfile)

      #if need_create
        ActiveRecord::Schema.define do

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

          if !table_exists? :ipvotes
            create_table :ipvotes do |table|
              table.column :user_id, :integer
              table.column :ip, :string
              table.column :vote, :integer
              table.column :created_at, :datetime
              table.column :content_id, :string
            end
          end

          add_index(:contents, :url, :unique => true) if !index_exists?(:contents, :url, :unique => true)
          add_index(:ipvotes, [:content_id, :user_id], :unique => true) if !index_exists?(:ipvotes, [:content_id, :user_id], :unique => true)
        end
      #end
    else
      ActiveRecord::Base.establish_connection cfg[options[:env]]
    end
  end
end

class Content < ActiveRecord::Base
end


