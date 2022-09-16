require 'sinatra/base'
require "sinatra/reloader"

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    return erb(:index)
  end

  post '/hello' do
  input = params[:name]
  if input.gsub(/[^0-9a-z ]/i, "") != input
    @name = "£££"
  else
    @name = input
  end
    return erb(:hello)
  end
end
