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

```
$ cat ~/ops/repos/target/basic_config 
host			hostname			env			user	roles
bastion 		192.168.56.1	     production	hoge	base:apache
produciont-svr	192.168.56.8		production	root	base
host,attrs

$ utils/generate_json_properties.rb -t 'json' > properties.yml
$ cat properties.yml
[
  {
    "host": "bastion",
    "hostname": "192.168.56.1",
    "env": "development",
    "user": "hoge",
    "roles": [
      "base",
      "apache"
    ]
  },
  {
    "host": "vmcentos70key",
    "hostname": "192.168.56.8",
    "env": "production",
    "user": "root",
    "roles": [
      "base"
    ]
  }
]
```
    

- rake -T
テストケースを表示
> \$ rake -T
rake serverspec:tst-vmcentos70a   # Run serverspec to tst-vmcentos70a
rake serverspec:tst-vmcentos70b   # Run serverspec to tst-vmcentos70b
rake serverspec:tst-vmcentos70ba  # Run serverspec to tst-vmcentos70ba
rake spec                         # Run serverspec to all servers

- Serverspec実行
  > \$ for s in \$(rake -T | grep -v 'all servers'|awk '{print \$2}');do echo "[Spec]\$s:"; rake \$s SPEC_OPTS="--format html" >\${s}.html ; done

- ~/.ssh/config
ファイル作成 
> \$ utils/generate_properties.rb -t 'ssh'  > ~/.ssh/config

- 出力結果：鍵認証（パス無し）でログインするホスト

```
Host bastion
    User            hoge
    HostName        192.168.56.1
    IdentityFile    ~/.ssh/id_rsa
    Port            22
    StrictHostKeyChecking no
    ConnectTimeout  3
```

- プロパティファイルにてenv=production定義があるエントリ
bastion経由でのアクセス設定値（ProxyCommand）が出力される。
```
Host production-server
    User            root
    HostName        192.168.56.8
    IdentityFile    ~/.ssh/id_rsa
    Port            22
    StrictHostKeyChecking no
    ConnectTimeout  3
    ProxyCommand ssh bastion nc %h %p
```
