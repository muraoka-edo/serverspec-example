* サーバースペック（個人用設定）
---

** [やりたい事]
- 複数ホストに対してリモート(ssh)でServerspec実行
<br>

** 事前作業

*** 1. SSH鍵設定
ポート番号（22番以外）や多段sshを"~/.ssh/config"で吸収
> \$ vi ~/.ssh/config

** 2. プロパティファイル作成
> \$ cat utils/tmpl/properties.base
host,attrs
test-server,base
\$ utils/print_properties.yml.rb utils/tmpl/properties.base > properties.yml
\$ cat properties.yml
---
test-server:
  :roles:
  - base
  :host_name: test-server

