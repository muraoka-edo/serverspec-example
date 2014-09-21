# サーバースペック（備忘録）

---

## やりたい事
- 複数ホストに対してリモート(ssh)でServerspec実行
<br>

## 事前作業

- SSH鍵設定
ポート番号（22番以外）や多段sshを"~/.ssh/config"で吸収

     > \$ vi ~/.ssh/config

- プロパティファイル（接続ホスト情報）作成

    > \$ cat utils/tmpl/properties.base
    host,attrs
    test-server,base
    \$ utils/print_properties.yml.rb utils/tmpl/properties.base > properties.yml
    \$ cat properties.yml
    \---
    test-server:
       :roles:
       \- base
    :host_name: test-server

- rake -T
テストケースを表示
> \$ rake -T
rake serverspec:tst-vmcentos70a   # Run serverspec to tst-vmcentos70a
rake serverspec:tst-vmcentos70b   # Run serverspec to tst-vmcentos70b
rake serverspec:tst-vmcentos70ba  # Run serverspec to tst-vmcentos70ba
rake spec                         # Run serverspec to all servers

- Serverspec実行
  > \$ for s in \$(rake -T | grep -v 'all servers'|awk '{print \$2}');do echo "[Spec]\$s:"; rake \$s SPEC_OPTS="--format html" >\${s}.html ; done

- .ssh/config
パスワード認証でログインするホスト
  >\ $ cat ~/.ssh/config
    Host tst-vmcentos70a
    User            hoge
    HostName        vmcentos70a
    Port            22

   鍵認証（パス無し）でログインするホスト
   >Host tst-vmcentos70b
    User            edo
    HostName        vmcentos70b
    IdentityFile    ~/.ssh/id_rsa_2048_edo_mac.local
    Port            22
   
   鍵認証（tst-vmcentos70）経由でパスワード認証（tst-vmcentos70a）のサーバへログイン
   > Host tst-vmcentos70ba
    User            hoge
    HostName        vmcentos70a
    Port            22
    ProxyCommand ssh -W %h:%p tst-vmcentos70b

