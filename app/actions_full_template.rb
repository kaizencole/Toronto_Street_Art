# Homepage (Root path)
get '/' do
  @pictures = Picture.all
  erb :index
end

post '/search' do
  @street1 = params[:search1]
  @street2 = params[:search2]
  @intersection = Intersection.find_all_by_address(@street1, @street2)
  erb :'/intersections/show'
end

## -------- Picture Controllers -------- ##

# Index
  get '/pictures' do
    @pictures = Picture.all
    erb :index
  end

# New
  get '/pictures/new' do
    @picture = Picture.new
    erb :'pictures/@picture.id'
  end

# Show
  get '/pictures/:id' do
    @picture = Picture.find(id: params[:id])
    if @picture
      redirect "/pictures/#{@picture.id}"
    else
      erb :'/error_pages/404'
    end
  end

# Create
  post '/pictures' do
    @street1 = params[:street1]
    @street2 = params[:street2]
    @intersection = Intersection.find_all_by_address(@street1, @street2)

    if @intersection
      @new_picture = Picture.new(
        intersection_id = @intersection
        user_id: params[:user_id]
        img_url: params[:img_url]
        artist_name: params[:artist_name]
        text: params[:text]
        )
    else
      @new_intersection = intersection.New(@intersection)
      @new_picture = Picture.new(
        intersection_id = @new_intersection
        user_id: params[:user_id]
        img_url: params[:img_url]
        artist_name: params[:artist_name]
        text: params[:text]
        )
    end
    @new_picture.save
    redirect :user_page
  end

# Delete
  post '/pictures/:id' do
    @picture = Picture.find(id: params[:id])
    @picture.destroy
  end



## -------- User Controllers -------- ##

# Index
  get '/users' do
    @users = User.all
    erb :index
  end

# New
get '/users/new' do
  @user = User.new
  erb :user_page
end

# Show
get '/users/:id' do
  @user = User.find(params[:id])
  if @user
    redirect "/users/#{@user.id}"
  else
    erb :'/error_pages/404'
  end
end

# Create
post '/users/' do
  @user = User.new(
    name: params[:name]
    email: params[:email]
    password: params[:password_digest]
  )
  if @user.save
    erb :user_page
  else
    erb :index
  end
end



## -------- Session Controllers -------- ##

# Login

get '/login' do
    erb :login
  end

  def current_user
    if cookies.key? :remember_me
      user = User.find_by_remember_token(cookies[:remember_me])
      return user if user
    end

    if session.key?(:user_session)
      user = User.find_by_login_token(session[:user_session])
    end
  end

  get '/login' do
    if current_user
      erb :user_page
    else
      redirect '/login'
    end
  end

  post '/session' do
    @user = User.find_by_email(params[:email])

    if @user && @user.authenticate(params[:password])
      session[:user_session] = SecureRandom.hex
      @user.login_token = session[:user_session]

      if params.key?('remember_me') && params[:remember_me] == 'true'

        if @user.remember_token
          response.set_cookie :remember_me, value: @user.remember_token, max_age: '2592000'
        else
          response.set_cookie :remember_me, value: SecureRandom.hex, max_age: '2592000'
          @user.remember_token = cookies[:remember_me]
        end
      end
    end

    @user.save
  end
#end

# Logout

get '/logout' do
  if current_user
    session.clear
    redirect :'/'
  end
end


## -------- Intersection Controllers -------- ##

# # index
get '/intersections' do
  @intersection = Intersection.all
  erb :index
end

# new
get '/intersections/new' do
  @intersection = Intersection.new
  redirect "/intersections/#{@intersection.id}"
end

# show
get '/intersections/:id' do
  @intersection = Intersection.find_by(
    street1: params[:street1],
    street2: params[:street2]
  )
  if @intersection
    erb :'/intersections/show'
  else
    erb :'/error_pages/404'
  end
end

# Create
post '/intersections/' do
  @intersection = Intersection.new(
    street1: params[:street1]
    street2: params[:street2]
  )
  if @intersection.save
    redirect "/intersections/#{@intersection.id}"
  else
    erb :'/error_pages/404'
  end
end
