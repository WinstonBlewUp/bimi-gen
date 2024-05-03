class AddConverterIdToLogos < ActiveRecord::Migration[7.1]
  def change
    add_column :logos, :converter_id, :integer
  end
end
