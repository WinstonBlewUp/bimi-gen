require 'net/https'
require 'net/http/post/multipart'
require 'json'
require 'open-uri'

class Logo < ApplicationRecord
  has_one_attached :photo
  has_one_attached :svg_attachment

  # before_save :resize_png

  validates :title, presence: true
  validates :title, length: { maximum: 60 }

  # before_save :resize_png

  validates :photo, attached: true, content_type: ['png'], aspect_ratio: :square

  def resize_png
    return unless photo.attached?
    # Download the image and process it with MiniMagick

    # Fetch the Cloudinary URL of the image
    cloudinary_url = Cloudinary::Utils.cloudinary_url(photo.key)

    # Process the image with MiniMagick
    # resized_image = MiniMagick::Image.open(photo.url)
    # resized_image.resize "50x50"

    # Create a new blob with the resized image
    # resized_image_blob = ActiveStorage::Blob.create_and_upload!(
    #   io: File.open(resized_image.path),
    #   filename: "resized_#{photo_blob.filename}",
    #   content_type: photo_blob.content_type
    # )

    # Attach the resized image to the model
    # self.photo.attach(resized_image_blob)

    # Clean up the temporary file
    # File.delete(resized_image.path)
  end

  def fetch_file_id
    api_key = ENV['ZIMZAR_API_KEY']
    endpoint = "https://sandbox.zamzar.com/v1/jobs/#{converter_id}"
    uri = URI(endpoint)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(api_key, '')
      response = http.request(request)
      data = JSON.parse(response.body)
      if data["target_files"].length > 0
        update(file_id: data["target_files"][0]["id"])
      end
    end
  end

  def fetch_svg_file
    api_key = ENV['ZIMZAR_API_KEY']
    uri = URI("https://sandbox.zamzar.com/v1/files/#{file_id}/content")
    response = ""
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(api_key, '')      
      response = http.request(request)
    end
    update(svg_code: response.body)
  end

  def custom_svg
    svg_array = svg_code.partition("<g")
    header = svg_array[0]
    a = header.partition("<svg")
    a[0] = "<?xml version=\"1.0\" encoding=\"utf-8\"?> "
    svg_tag = a[1].split("<svg", 2)
    svg_tag[0] = "<svg version=\"1.2\" baseProfile=\"tiny-ps\" id=\"svg#{id}\""
    a[2] = a[2].sub("version=\"1.1\"", '')
    a[1] = svg_tag.join
    initial_header = a.join
    complete_header = add_title_tag(initial_header)
    svg_array[0] = complete_header
    return svg_array.join
  end
  
  def add_title_tag(header)
    tle = "<title>#{title}</title> "
    des = "<description>#{description}</description> " if description.length > 0
    return "#{header}#{tle}#{des}"
  end

end