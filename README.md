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

```
$ rake -T
rake serverspec:tst-vmcentos70a   # Run serverspec to tst-vmcentos70a
rake serverspec:tst-vmcentos70b   # Run serverspec to tst-vmcentos70b
rake serverspec:tst-vmcentos70ba  # Run serverspec to tst-vmcentos70ba
rake spec                         # Run serverspec to all servers
```

- Serverspec実行
```
$ for s in \$(rake -T | grep -v 'all servers'|awk '{print \$2}');do echo "[Spec]\$s:"; rake \$s SPEC_OPTS="--format html" >\${s}.html ; done
```

- ~/.ssh/config
ファイル作成 
```
$ utils/generate_properties.rb -t 'ssh'  > ~/.ssh/config
```

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

- ディレクトリ構成
```
ops
├── repos
│   ├── server_config.git
│   ├── target
│   │   ├── basic_config
│   │   ├── files
│   │   │   └── flst.tmpl
│   │   └── hosts
│   │       └── hostlst.txt
│   └── worktree
├── git-compare
│   ├── capistrano
│   │   ├── Capfile
│   │   └── config
│   │       └──  deploy.rb
│   ├── extlib
│   │   └── plogger.rb
│   ├── logs
│   │   └── deploy.rb.log
│   └── scripts
│       ├── archive_file.rb
│       ├── rake_register_git.rb
│       └── scpfiles
│           ├── downloads
│           └── uploads
└── serverspec-example
    ├── README.md
    ├── Rakefile
    ├── properties.json
    ├── spec
    │   ├── base
    │   │   └── common_spec.rb
    │   └── spec_helper.rb
    └── utils
        └── generate_properties.rb
```


---
あとで修正

- ~/.ssh/config
   踏み台サーバー

```
Host bastion
     User            hoge
     HostName        vmcentos64key
     IdentityFile    ~/.ssh/id_rsa
     Port            22  
```

   接続先サーバー

```
Host vmcentos70key
    User            hoge
    HostName        192.168.56.8
    IdentityFile    ~/.ssh/keys/id_rsa_vmcentos64key
    Port            22  
    ProxyCommand ssh bastion nc %h %p
    

{"bastion"=>
   {:roles=>["base", "apache"],
    :host_name=>"bastion"}
 }
```

- 途中でエラーがでても終了しない
http://qiita.com/haazime/items/1cfab4e1e34b23f20ce1



```
$ ./print_properties.rb tmpl/properties.base.csv  > print_properties.rb
$ cat properties.json 
[
  {
    "host": "bastion",
    "hostname": "vmcentos64key",
    "env": "production",
    "user": "hoge",
    "roles": [
      "base"
    ]
  },
  {
    "host": "vmcentos70key",
    "hostname": "192.168.56.8",
    "env": "production",
    "user": "edo",
    "roles": [
      "base"
    ]
  }
]
```

- rake -T
テストケースを表示
```
$ rake -T
rake serverspec:tst-vmcentos70a   # Run serverspec to tst-vmcentos70a
rake serverspec:tst-vmcentos70b   # Run serverspec to tst-vmcentos70b
rake serverspec:tst-vmcentos70ba  # Run serverspec to tst-vmcentos70ba
rake spec                         # Run serverspec to all servers
```

実行
```
$ for s in \$(rake -T | grep -v 'all servers'|awk '{print \$2}');do echo "[Spec]\$s:"; rake \$s SPEC_OPTS="--format html" >\${s}.html ; done
```

```
$ cat Rakefile 
require 'rake'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'
require 'json'

servers = JSON.parse(File.read('properties.json'))

desc "Run serverspec to all servers"
task :spec => 'serverspec:all'

class ServerspecTask < RSpec::Core::RakeTask
  attr_accessor :target_host, :target_env

  def spec_command
    cmd = super
    "env TARGET_HOST=#{target_host} \
         TARGET_ENV=#{ target_env } \
    #{cmd}"
  end
end

namespace :serverspec do
  task :all => servers.map {|s| 'serverspec:' + s['host'] }
  servers.each do |server|
    desc "Run serverspec to #{server['host']}"
    ServerspecTask.new(server['host'].to_sym) do |t|
      t.target_host = server['host']
      t.target_env  = server['env' ]
      t.pattern = 'spec/{' + server['roles'].join(',') + '}/*_spec.rb'
      t.fail_on_error = false
    end
  end
end
```
