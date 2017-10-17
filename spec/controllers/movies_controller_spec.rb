require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
    it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      fake_results = [double('movie1'), double('movie2')]
      allow(Movie).to receive(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end
  end
  describe 'searching TMDb with no value' do
    it 'should be redirected to the index page' do
      post :search_tmdb, {:search_terms => ''}
      expect(response).to redirect_to '/movies'
      expect(flash[:notice]).to eq 'Invalid search term'
    end
  end
  describe 'searching TMDb with a value which yeilds no results' do
    it 'should call the model that performs TMDb search and then, be redirected to the index page' do
      fake_results = []
      allow(Movie).to receive(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {:search_terms => 'xasfaff'}
      expect(response).to redirect_to '/movies'
      expect(flash[:notice]).to eq 'No matching movies were found on TMDb'
    end
  end
  describe 'adding records from TMDb' do
    describe 'selecting movies' do
      it 'should call the model method that adds the selected movies to database' do
        fake_results = [double('movie1'), double('movie2')]
        allow(Movie).to receive(:create_from_tmdb).with('12259').and_return (fake_results)
        post :add_tmdb, {:tmdb_movies => {"12259" => "1"}}
        expect(flash[:notice]).to eq 'Movies successfully added to Rotten Potatoes'
        expect(response).to redirect_to '/movies'
      end
    end
    describe 'not selecting movies' do
      it 'should be redirected to the index page' do
        post :add_tmdb, {}
        expect(response).to redirect_to '/movies'
        expect(flash[:notice]).to eq 'No movies selected'
      end
    end
  end
  describe 'new movie' do
    it 'should render a template to add movie' do
      get :new
      expect(response).to render_template('new')
    end
  end
  describe 'edit movie' do
    it 'should render a template to edit a movie' do
      fake_results = [double('movie1'), double('movie2')]
      allow(Movie).to receive(:find).with('1').and_return (fake_results)
      get :edit, {:id => 1}
      expect(response).to render_template('edit')
    end
  end
  #describe 'delete movie' do
  #  it 'should delete the movie and redirect to the index page' do
  #    fake_results = double('movie1')
  #    expect(Movie).to receive(:find).with('1').and_return (fake_results)
  #    delete :destroy, {:id => 1}
  #    expect(response).to redirect_to '/movies'
  #    expect(flash[:notice]).to eq 'Movie movie1 deleted'
  #  end
  #end
end
