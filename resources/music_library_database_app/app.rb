# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  get '/albums' do
    repo = AlbumRepository.new
    @albums = repo.all
    return erb(:albums)
  end

  get '/albums/new' do
    return erb(:create_album)
  end

  post '/albums' do
    if invalid_album_parameters?
      status 400
      return 'Bad request!'
    end
    title = params[:title]
    release_year = params[:release_year]
    artist_id = params[:artist_id]
    repo = AlbumRepository.new
    @new_album = Album.new
    @new_album.title = title
    @new_album.release_year = release_year
    @new_album.artist_id = artist_id
    repo.create(@new_album)
    return erb(:album_created)
  end

  get '/artists' do
    repo = ArtistRepository.new
    @artists = repo.all
    return erb(:artists)
  end

  get '/artists/new' do
    return erb(:create_artist)
  end

  post '/artists' do
    if invalid_artist_parameters?
      status 400
      return 'Bad request!'
    end
    name = params[:name]
    genre = params[:genre]
    repo = ArtistRepository.new
    @new_artist = Artist.new
    @new_artist.name = name
    @new_artist.genre = genre
    repo.create(@new_artist)
    return erb(:artist_created)
  end

  get '/albums/:id' do
    repo = AlbumRepository.new
    @album = repo.find(params[:id])
    artist_repo = ArtistRepository.new
    @artist = artist_repo.find(@album.artist_id)
    return erb(:index)
  end

  get '/artists/:id' do
    repo = ArtistRepository.new
    @artist = repo.find(params[:id])
    album_repo = AlbumRepository.new
    @albums = album_repo.find_albums(params[:id])
    return erb(:artist)
  end

  def invalid_artist_parameters?
    params[:name] == nil || params[:genre] == nil 
  end

  def invalid_album_parameters?
    params[:title] == nil || params[:release_year] == nil
  end
end