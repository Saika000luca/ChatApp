require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'active_record'
require 'sinatra-websocket'




enable :sessions

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "./bbs.db"
)

class Comment < ActiveRecord::Base
end

class Auth < ActiveRecord::Base
end

get '/' do
  @title = "チャットサイトをつくってみた"  
  @comments = Comment.order("id desc").all
  @userName = session[:userName]
  erb :index
end


post '/new'do 
  Comment.create({:userName => params[:userName],
                  :chatroomId => nil,
                  :chatroomName => "トップアプリ",
                  :body => params[:body]})
  redirect '/'
end


get '/chatroom_site' do
  @chatroom = Comment.select("chatroomId, chatroomName").distinct.order("created_at desc")
  erb :MakeChatroom
end

post '/Make_chatroom' do
  #sum = 0
  sum = Comment.select("chatroomId").maximum(:chatroomId)
  sum += 1
  #@erb_sum = sum
  Comment.create({:chatroomId => sum,
                  :chatroomName => params[:chatroomName]})
  redirect '/chatroom_site'
end


get '/login' do
    erb :makeUser
end


get '/logout' do
  session[:userName] = nil
  session[:authenticated] = false
  redirect '/chat_logout'
end

get '/chat_logout' do
  "ログアウトしました。"
end


#データベースからuserNameとpasswordが一致するものをauthに格納
#auth.countが0なら一致しなかったこととなる。
#その後sessionを用いて認証されているか判断する
post '/user_auth' do

    auth = Auth.where("userName = ? AND password = ?",
               params[:userName], params[:password]) 

    if auth.count == 0
      "ログインできませんでした"
    else
      session[:userName] = params[:userName]
      session[:authenticated] = true
      "ログインしました"
    end
end


#ユーザーが既に存在しているかだけの条件で判断している
#今後新規登録方法を変えた方が良いだろう
post '/new_auth' do

  if Auth.where("userName = ?", params[:userName]).count == 1
    redirect '/user_already_exist'
  else
  Auth.create({:userName => params[:userName],
               :password => params[:password]})

  "新規登録しました"
  end
  

end

get '/user_already_exist' do
  "すでにユーザーが存在します"
end


get '/chat_logined' do
  "すでにログインしています。"
end

get '/id/:num/:name' do
  @id = Comment.where(chatroomId: params[:num]).order("id desc").all
  @title = params[:name]
  @name = @title
  @num = params[:num]
  erb :chat
end

post '/chat/:num/:name' do
  Comment.create({:userName => params[:userName],
                  :chatroomId => params[:num],
                  :chatroomName => params[:name],
                  :body => params[:body]})
  redirect "/id/#{params[:num]}/#{params[:name]}"

end


#sessionを用いてユーザーが認証されているか確認
#requeset.pathの場所なら/loginにredirectすることでユーザー認証を強制させている
before do
  unless session[:authenticated]
    if request.path != "/login" && request.path != "/user_auth" && 
        request.path != "/new_auth" && request.path != "/user_already_exist" && request.path != "/chat_logout"
       redirect '/login'
    end
  end
end



after do
  ActiveRecord::Base.clear_active_connections!
end
