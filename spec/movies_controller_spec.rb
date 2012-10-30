require 'spec_helper'

describe MoviesController, :type => :controller do
  
  before :each do
    @fake_results = [mock('Movie'), mock('Movie'), mock('Movie')]
    i = 0
    @fake_results.each do |movie|
      movie.stub(:id).and_return(i)
      movie.stub(:title).and_return("Movie " + i.to_s)
      movie.stub(:director).and_return("John Doe")
      i = i + 1
    end
    @fake_movie = mock('Movie')
    @fake_movie.stub(:director).and_return("John Doe")
    Movie.stub(:find).and_return(@fake_movie)
    Movie.stub(:find_all_by_director).and_return(@fake_results)
  end
  
  describe 'searching for same director' do
    it 'should call the model method to find the movie based on the id in the URI' do
      Movie.should_receive(:find).with('3')
      get :similar, {:id => 3}
    end
    it 'should call the model method that performs the director search' do
      Movie.should_receive(:find_all_by_director).with("John Doe")
      get :similar, {:id => 3}
    end
  end
end