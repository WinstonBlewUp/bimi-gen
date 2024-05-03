class PagesController < ApplicationController
    def new
        render file: "#{Rails.root}/app/views/logos/new.html.erb", layout: false
    end
  end