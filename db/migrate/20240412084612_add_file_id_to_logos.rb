class AddFileIdToLogos < ActiveRecord::Migration[7.1]
  def change
    add_column :logos, :file_id, :integer
  end
end
