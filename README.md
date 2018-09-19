# install
このアプリケーションを動かす時は以下のコマンドを
入力してください。
```
$ git clone https://github.com/SyunTana/ChatApp
```
その後、bundleで必要なgemをインストールします
```
$ bundle install --path=vendor/bundle
```
gemまたは、bundleをインストールしていない人は
以下のコマンドでインストールしておいてください。
```
$ sudo apt install gem
```
```
$ sudo gem install bundle
```
これで、環境は整ったので、以下のコマンドで
アプリを起動します
```
$ bundle exec ruby app.rb -o 0.0.0.0
```
ブラウザを開いて、
  localhost:4567
と入力してください。
これで、チャットアプリでユーザー登録やチャット部屋
を作ったりしてみてください。
