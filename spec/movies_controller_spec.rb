require 'spec_helper'

describe MoviesController, :type => :controller do
  
  describe 'show the index' do
    before :each do
      @fake_results = [mock('Movie'), mock('Movie'), mock('Movie')]
      i = 0
      @fake_results.each do |movie|
        movie.stub(:id).and_return(i)
        movie.stub(:title).and_return("Movie " + i.to_s)
        movie.stub(:director).and_return("John Doe")
        i = i + 1
      end
      Movie.stub(:find_all_by_rating).and_return(@fake_results)
      Movie.stub(:all_ratings).and_return(%w(G PG PG-13 NC-17 R))
    end
    
    it 'should set the order to title when the sort param is set to title' do
      get :index, {:sort => 'title'}
      assigns(:title_header).should == 'hilite'
    end
    
    it 'should set the order to release_date when the sort key in the session is set to release_date and params are empty' do
      session[:sort] = 'release_date'
      get :index
      assigns(:date_header).should == 'hilite'
    end
    
    it 'should make a call to the model method to get all the ratings' do
      Movie.should_receive(:all_ratings)
      get :index
    end
    
    it 'should make all the ratings available to the view' do
      get :index
      assigns(:all_ratings).should == %w(G PG PG-13 NC-17 R)
    end
    
    it 'should set the selected ratings to all the ratings if none are selected in params or session' do
      get :index
      assigns(:selected_ratings).should == Hash[%w(G PG PG-13 NC-17 R).map {|rating| [rating, rating]}]
    end
    
    it 'should set session sort order to params sort order if they differ' do
      session[:sort] = 'release_date'
      get :index, {:sort => 'title'}
      session[:sort].should == 'title'
    end
    
    it 'should set session ratings to params ratings if they differ' do
      session[:ratings] = {:PG => 'PG', :R => 'R'}
      get :index, {:ratings => {:G => 'G'}}
      session[:ratings].should == {"G" => "G"}
    end
    
    it 'should make a call to the model method to get all movies with the selected the ratings' do
      Movie.should_receive(:find_all_by_rating).and_return(@fake_results)
      get :index
    end
    
    it 'should make the sorted movies for the selected ratings available to the view' do
      get :index
      assigns(:movies).should == @fake_results
    end
      
  end
  
  describe 'update a movie' do
    before :each do
      @fake_movie = mock('Movie')
      @fake_movie.stub(:title).and_return("A Movie")
      @fake_movie.stub(:update_attributes!)
      Movie.stub(:find).and_return(@fake_movie)
    end
    
    it 'should look up the movie using the id from the URI' do
      Movie.should_receive(:find).with('3').and_return(@fake_movie)
      put :update, {:id => 3}
    end
    
    it 'should make the movie available to the template' do
      put :update, {:id => 3}
      assigns(:movie).should == @fake_movie
    end
    
    it 'should redirect to the movie details' do
      put :update, {:id => 3}
      response.should redirect_to(movie_path(@fake_movie))
    end
      
    it 'should show a notification in the flash' do
      put :update, {:id => 3}
      flash[:notice].should =~ /#{@fake_movie.title} was successfully updated./i
    end
    
  end
  
  describe 'show a movie' do
    it 'should look up the movie using the id from the URI' do
      Movie.should_receive(:find).with('3')
      get :show, {:id => 3}
    end
    
    it 'should make the movie available to the template' do
      @fake_movie = mock('Movie')
      Movie.stub(:find).and_return(@fake_movie)
      get :show, {:id => 3}
      assigns(:movie).should == @fake_movie
    end
  end
  
  describe 'create a movie' do
    before :each do
      @new_movie = {:movie => {:title => "New Movie"}}
      @fake_movie = mock('Movie')
      @fake_movie.stub(:title).and_return("A Movie")
      Movie.stub(:create!).and_return(@fake_movie)
    end
    
    it 'should make a call to the model method to create a movie' do
      Movie.should_receive(:create!).with({"title" => "New Movie"}).and_return(@fake_movie)
      post :create, @new_movie
    end
    
    it 'should make the movie available to the template' do
      post :create, @new_movie
      assigns(:movie).should == @fake_movie
    end
    
    it 'should redirect to the index' do
      post :create, @new_movie
      response.should redirect_to(movies_path)
    end
      
    it 'should show a notification in the flash' do
      post :create, @new_movie
      flash[:notice].should =~ /#{@fake_movie.title} was successfully created./i
    end
  end
  
  describe 'destroy a movie' do
    before :each do
      @fake_movie = mock('Movie')
      @fake_movie.stub(:title).and_return("A Movie")
      @fake_movie.stub(:destroy)
      Movie.stub(:find).and_return(@fake_movie)
    end
    
    it 'should look up the movie using the id from the URI' do
      Movie.should_receive(:find).with('3').and_return(@fake_movie)
      post :destroy, {:id => 3}
    end
    
    it 'should make the movie available to the template' do
      post :destroy, {:id => 3}
      assigns(:movie).should == @fake_movie
    end
    
    it 'should redirect to the index' do
      post :destroy, {:id => 3}
      response.should redirect_to(movies_path)
    end
      
    it 'should show a notification in the flash' do
      post :destroy, {:id => 3}
      flash[:notice].should =~ /Movie '#{@fake_movie.title}' deleted./i
    end
  end
  
  describe 'edit a movie' do
    it 'should look up the movie using the id from the URI' do
      Movie.should_receive(:find).with('3')
      get :edit, {:id => 3}
    end
  end
  
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