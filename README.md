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

- Serverspec実行
  > \$ rake spec
