# Keeptrying

KPT振り返りミーティングで話す内容をCUIでメモするツールです。

## インストール

    $ gem install keeptrying

## Usage

### 内容を見る

	$ kpt show [-k|p|t] [days]
	または
	$ kpt s
	
	メモした内容を閲覧します。
	-k/p/tを付けるとそれぞれのタグがついたメモを表示します。
	日数を指定するとその日数以内のメモを表示します。

### 内容を書く

	$ kpt write -k|p|t [message] (or kpt w)

	内容をメモします。
	タグ(-k/p/t)は必須です。
	タグの後に続けて内容を書けばそのまま保存されます。
	内容を省略するとエディタを起動します。
	エディタは環境変数EDITORで指定します。

### 完了フラグを付ける

	$ kpt done [days] (or kpt d)
	
	完了フラグを付けます。
	日数を指定しないと現在の全ての内容を完了にします。
	完了にした内容はkpt showで表示されなくなります。

### 全ての内容を表示する

	$ kpt all [-k|-p|-t] [days] (or kpt a)

	完了にしたものも含めて全ての内容を表示します。

### 古い内容を削除する

	$ kpt truncate days (or kpt t)

	古い内容を削除します。
	日数を必ず指定して下さい。
	完了フラグのついているもののみ削除されます。

## その他のオプション

### データベースファイルを指定する

	$ KPT_DB=~/databases/kpt.sqlite kpt show
	
	環境変数KPT_DBを設定します。

### エディタを指定する

	$ EDITOR=emacs kpt write -k

	環境変数EDITORを設定します。

### アンインストール

	~/.kpt(またはKPT_DBで指定したファイル)を削除して下さい。

## Contributing

1. Fork it ( http://github.com/<my-github-username>/keeptrying/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
