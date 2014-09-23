# サーバースペック（備忘録）

---

## やりたい事
- 多段ssh経由でServerspec実行
<br>

## 事前作業

### SSH鍵設定（~/.ssh/config）
多段sshを"~/.ssh/config"で吸収（ncコマンド）
(ssh -W は Opensshバージョン5.4から利用可能な為、CentOS6.X だと利用できない）
     > $ cat /etc/redhat-release 
CentOS release 6.4 (Final)
\$ ssh -v
OpenSSH_5.3p1, OpenSSL 1.0.0-fips 29 Mar 2010


- Serverspec実行
  > \$ for s in \$(rake -T | grep -v 'all servers'|awk '{print \$2}');do echo "[Spec]\$s:"; rake \$s SPEC_OPTS="--format html" >\${s}.html ; done

- ~/.ssh/config
   踏み台サーバー
   > Host bastion
        User            hoge
        HostName        vmcentos64key
        IdentityFile    ~/.ssh/id_rsa
        Port            22  
    
   接続先サーバー
> Host vmcentos70key
    User            hoge
    HostName        192.168.56.8
    IdentityFile    ~/.ssh/keys/id_rsa_vmcentos64key
    Port            22  
    ProxyCommand ssh bastion nc %h %p

### プロパティファイル作成
> \$ ./print_properties.rb tmpl/properties.base.csv  > print_properties.rb
\$ cat properties.json 
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

### テストケースを表示
>\$ rake -T
rake serverspec:bastion        # Run serverspec to bastion
rake serverspec:vmcentos70key  # Run serverspec to vmcentos70key
rake spec                      # Run serverspec to all servers

### Serverspec実行（HTML形式で保存）
>\$ for s in \$(rake -T | grep -v 'all servers'|awk '{print \$2}');do echo "[Spec]\$s:"; rake \$s SPEC_OPTS="--format html" >\${s}.html ; done
