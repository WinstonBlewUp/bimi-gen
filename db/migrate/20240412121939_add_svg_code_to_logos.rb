class AddSvgCodeToLogos < ActiveRecord::Migration[7.1]
  def change
    add_column :logos, :svg_code, :text
  end
end
