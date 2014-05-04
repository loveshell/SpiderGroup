class AddPublishtimeToContents < ActiveRecord::Migration
  def change
    add_column :contents, :publishtime, :datetime
  end
end
