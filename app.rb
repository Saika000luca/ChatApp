require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'active_record'
require 'sinatra-websocket'



#Bundler.require

#sum = 
#@erb_sum = 0
#chatRoom = []

=begin
set :server, 'thin'
set :sockets, []

get '/websocket' do
  if !request.websocket?
                  
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        settings.sockets.each do |s|
          s.send(msg)
        end
      end
    end
  end
end
=end

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

#post '/new_chatroom' do
#  Comment.create({:userName => params[:userName],
#                  :body => params[:body]})
#end



get '/chatroom_site' do
  #count += 1
  #@chatroom = Comment.order("id desc").all
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
  #p 1
  #@userName = session[:userName]
  session[:userName] = nil
  #@session = false
  session[:authenticated] = false
  #Auth.select("authenticated") = false
  redirect '/chat_logout'
end

get '/chat_logout' do
  "ログアウトしました。"
end

post '/user_auth' do

    auth = Auth.where("userName = ? AND password = ?",
               params[:userName], params[:password]) 

    if auth.count == 0
      redirect '/login_fault'
    end

    #if Auth.select("authenticated") then
    #  "すでにログインしています"
    #else
      session[:userName] = params[:userName]
      session[:authenticated] = true
      #Auth.select("authenticated") = true
      redirect '/chat_login' #ログインしました。
  #if session[:userName] != params[:userName] 
      #session[:userName] = params[:userName]
      #session[:authenticated] = true
    #@session = true
    #|@userName = params[:userName]
    #p session[:authenticated]
    #p 1
      #redirect '/chat_login' #ログインしました。
    #p 2
    #redirect '/chat_logined'  #すでにログインしています。
end

get '/login_fault' do
  "ログインできませんでした"
end

post '/new_auth' do
  #p params[:userName]
  #p params[:password]

  if Auth.where("userName = ?", params[:userName]).count == 1
    redirect '/user_already_exist'
  else
  Auth.create({:userName => params[:userName],
               :password => params[:password]})

  #redirect '/user_login'
  "新規登録しました"
  end
  

end

get '/user_already_exist' do
  "すでにユーザーが存在します"
end

get '/user_login' do
  "新規登録"
end

get '/chat_login' do
  "ログインしました。"
end

get '/chat_logined' do
  "すでにログインしています。"
end

get '/id/:num/:name' do
  #@title = Commet
  #@id = Comment.find_by(chatroomId: params[:num])
  @id = Comment.where(chatroomId: params[:num]).order("id desc").all
  @title = params[:name]
  #@id = @id.order("id desc").all
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

before do
  #p session[:authenticatd]
  #p request.path
  unless session[:authenticated]
    if request.path != "/login" && request.path != "/user_auth" && 
        request.path != "/new_auth" && request.path != "/user_already_exist" &&        request.path != "/chat_logout"
       redirect '/login'
    end
  end
end


after do
  ActiveRecord::Base.clear_active_connections!
end
