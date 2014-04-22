class AddUseridToContents < ActiveRecord::Migration
  def change
    add_column :contents, :userid, :integer
  end
end
