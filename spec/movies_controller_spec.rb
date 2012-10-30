require 'spec_helper'

describe MoviesController, :type => :controller do
  
  describe 'searching for same director' do
    
    before :each do
      @fake_results = [mock('Movie'), mock('Movie'), mock('Movie')]
      i = 0
      @fake_results.each do |movie|
        movie.stub(:id).and_return(i)
        movie.stub(:title).and_return("Movie " + i.to_s)
        movie.stub(:director).and_return("John Doe")
        i = i + 1
      end
      Movie.stub(:find_all_by_director).and_return(@fake_results)
    end
    
    context 'searching on a movie that has a director' do
      before :each do
        @fake_movie = mock('Movie')
        @fake_movie.stub(:director).and_return("John Doe")
        Movie.stub(:find).and_return(@fake_movie)
      end
      
      it 'should call the model method to find the movie based on the id in the URI' do
        Movie.should_receive(:find).with('3')
        get :similar, {:id => 3}
      end
    
      it 'should call the model method that performs the director search' do
        Movie.should_receive(:find_all_by_director).with("John Doe")
        get :similar, {:id => 3}
      end
      
      context 'after searching' do
        before :each do
          get :similar, {:id => 3}
        end
        
        it 'should select the similar template for rendering' do
          response.should render_template('similar')
        end
      
        it 'should make the director search results available to that template' do
          assigns(:movies).should == @fake_results
        end
      
        it 'should make the movie available to that template' do
          assigns(:movie).should == @fake_movie
        end
      end
    end
    
    context 'searching on a movie that does not have a director' do
      before :each do
        @fake_movie = mock('Movie')
        @fake_movie.stub(:title).and_return('Movie with no Director')
        @fake_movie.stub(:director).and_return(nil)
        Movie.stub(:find).and_return(@fake_movie)
        get :similar, {:id => 3}
      end
      
      it 'should redirect to the index' do
        response.should redirect_to(movies_path)
      end
      
      it 'should show an error in the flash' do
        flash[:notice].should =~ /'#{@fake_movie.title}' has no director info/i
      end
    end
    
  end
  
end