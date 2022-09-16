require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

def reset_artists_table
  seed_sql = File.read('spec/seeds/artists_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end


describe Application do
  before(:each) do 
    reset_albums_table
    reset_artists_table
  end
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context 'GET /albums' do
    it "lists the albums" do
      response = get('/albums')
      expect(response.status).to eq(200)
      expect(response.body).to include("Title: Waterloo")
      expect(response.body).to include("<h1>Albums</h1>")
      expect(response.body).to include("<head></head>")
      expect(response.body).to include("Release year: 1982")
    end
  end

  context 'POST /albums' do
    it 'creates a new album' do
      response = post('/albums', title: 'Voyage', release_year: '2022', artist_id: '2')
      expect(response.status).to eq(200)
      response = get('/albums')
      expect(response.status).to eq(200)
      expect(response.body).to include("Voyage")
      expect(response.body).to include("Release year: 2022")
    end
  end


  #context 'GET /artists' do
    #it 'returns a list of artists' do
     # response = get('/artists')
     # expect(response.status).to eq(200)
     # expect(response.body).to eq "Pixies, ABBA, Taylor Swift, Nina Simone"
   # end
 #end
 

  context 'GET /artists' do
    it 'returns a list of artists with links' do
      response = get('/artists')
      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/artists/1" </a>')
    end
  end

  context 'GET /artists/new' do
    it "shows a form to create a new artist" do
      response = get('/artists/new')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Add an artist</h1>')
      expect(response.body).to include('<form action="/artists" method="POST">')
    end
  end

  context 'GET /artists/:id' do
    it "returns information from selected artist" do
      response = get('/artists/2')
      expect(response.status).to eq(200)
      expect(response.body).to include("<h1> ABBA </h1>")
      expect(response.body).to include("<head></head>")
      expect(response.body).to include("Pop")
    end
  end


  #context 'POST /artists' do
    #it "creates a new artist and adds to table" do
      #response = post('/artists', name: 'Wild nothing', genre: 'Indie')
      #expect(response.status).to eq(200)
      #response = get('/artists')
      #expect(response.status).to eq(200)
      #expect(response.body).to include('<a href="/artists/1" </a>')
   # end
  #end

  context 'GET to /albums/:id' do
    it 'returns data based off of album' do
      response = get('/albums/2')
      expect(response.status).to eq(200)
      expect(response.body).to include("Surfer Rosa")
      expect(response.body).to include("Pixies")
    end
  end

  context 'POST to /artists/new and do a bad request' do
    it 'gives a bad request error' do
      response = post('/artists', name: nil, genre: 'blues')
      expect(response.status).to eq(400)
      expect(response.body).to include("Bad request!")
    end
  end

  context 'POST to /albums/new and do a bad request' do
    it 'gives a bad request error' do
      response = post('/albums', title: "Hello world", release_year: nil, artist_id: "2")
      expect(response.status).to eq(400)
      expect(response.body).to include("Bad request!")
    end
  end
end
