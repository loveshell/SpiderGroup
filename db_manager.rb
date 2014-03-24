require 'active_record'

class DBManager
  attr_accessor :sqlite3_dbfile
  def initialize(options)
    @sqlite3_dbfile = "content.s3db"
    @sqlite3_dbfile = options[:dbfile]
    need_create = !File.exist?(@sqlite3_dbfile)
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database  => @sqlite3_dbfile)

    if need_create
      ActiveRecord::Schema.define do

        #drop_table :contents if table_exists? :contents
        create_table :contents do |table|
          table.column :title, :string
          table.column :created_at, :datetime
          table.column :url, :string
          table.column :author, :string
          table.column :cover, :string
          table.column :description, :text
          table.column :content, :text
          table.column :source, :string
        end

        add_index :contents, :url, :unique => true
      end
    end
  end
end

class Content < ActiveRecord::Base
end


