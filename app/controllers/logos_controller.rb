require "open-uri"
require 'net/https'
require 'net/http/post/multipart'
require 'json'

class LogosController < ApplicationController
  def index
    @logos = Logo.all
  end

  def new
    @logo = Logo.new
  end

  def create
    @logo = Logo.new(logo_params)
    @logo.converter_id = svg(@logo)
    if @logo.save
      redirect_to logo_path(@logo)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @logo = Logo.find(params[:id])
  end

  private

  def svg(logo)
    api_key = ENV['ZIMZAR_API_KEY']
    source_file = logo.photo.url
    target_format = "svg"
    endpoint = "https://sandbox.zamzar.com/v1/jobs"
    uri = URI(endpoint)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      request = Net::HTTP::Post::Multipart.new(
        uri.request_uri,
        'source_file' =>  source_file,
        'target_format' => target_format
      )
      request.basic_auth(api_key, '')
      response = http.request(request)
      data = JSON.parse(response.body)
      return data["id"].to_i
    end
  end

  def logo_params
    params.require(:logo).permit(:title, :description, :photo)
  end

end