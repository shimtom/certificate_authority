# Certificate Authority
認証局を提供するDocker Image.

## Configuration

### Environment Variables
* `ROOT_CA_SUBJECT` ルート認証局証明に使用するサブジェクト.デフォルトは`/C=JP/ST=Tokyo/L=City/O=Company/CN=ca.example.com`.`CN`(Common Name)は必須.
* `ROOT_CA_SAN DNS`: ルート認証局証明で使用するSAN属性. デフォルトは`root.example.com,DNS:www.root.example.com`.
* `SUB_CA_SUBJECT`: ルート認証局によって署名された中間認証の証明書に使用するサブジェクト. デフォルトは`/C=JP/ST=Tokyo/L=City/O=Company/CN=sub.example.com`.`CN`(Common Name)は必須.
* `SUB_CA_SAN DNS`: 中間認証局証明で使用するSAN属性. デフォルトは`sub.example.com,DNS:www.sub.example.com`.
* `CA_VALID_DAYS`: 認証局の有効日数.デフォルトは`3650`日.

### Volumes
* `/exports`: 作成した証明書,秘密鍵などはすべてこのディレクトリに配置される.


## Dokcer Image の実行
```bash
$ docker-compose up -d
```

## サーバー証明の発行と署名
1. 証明書発行要求を作成するための設定ファイル`openssl.cnf`を用意する.`%HOSTNAME%`はサーバーのドメインに変更.

    ```
    [ req ]
    default_bits          = 4096
    default_keyfile       = privkey.pem
    distinguished_name    = req_distinguished_name
    attributes            = req_attributes
    #x509_extensions       = v3_ca

    string_mask = utf8only
    req_extensions = v3_req

    [ req_distinguished_name ]
    countryName                = Country Name (2 letter code)
    countryName_default        = AU
    countryName_min            = 2
    countryName_max            = 2

    stateOrProvinceName            = State or Province Name (full name)
    stateOrProvinceName_default    = Some-State

    localityName                   = Locality Name (eg, city)

    0.organizationName             = Organization Name (eg, company)
    0.organizationName_default     = Internet Widgits Pty Ltd

    organizationalUnitName             = Organizational Unit Name (eg, section)

    commonName                = Common Name (e.g. server FQDN or YOUR name)
    commonName_max            = 64

    emailAddress            = Email Address
    emailAddress_max        = 64


    [ req_attributes ]
    challengePassword            = A challenge password
    challengePassword_min        = 4
    challengePassword_max        = 20

    unstructuredName        = An optional company name

    [ v3_req ]
    basicConstraints = CA:FALSE
    keyUsage = nonRepudiation, digitalSignature, keyEncipherment
    subjectAltName = @alt_names

    [alt_names]
    DNS.1=%HOSTNAME%
    DNS.2=*.%HOSTNAME%
    ```

2. サーバーの秘密鍵を作成する.
    * 暗号化する場合

        ```bash
        $ openssl genrsa -aes256 -out server.key 2048
        ```
        パスワードが求められるので入力する.
    * 暗号化しない場合
        ```bash
        $ openssl genrsa -out server.key 4096
        ```
3. 証明書署名要求を作成する.
```bash
$ openssl req -config openssl.cnf -new -key server.key -out server.csr -days 3650 -sha256
```

4. サーバー証明書を発行する  
```bash
$ docker exec openssl-ca /usr/local/bin/sign.sh root /export/server.csr example.com 3650
```
`example.com`のサーバー証明書をroot認証局が発行する.期限は3650日

## TODO
* [ ] CRTファイルのPEM形式への変換方法を追加
* [ ] 失効したサーバー証明書への対応方法を追加
* [ ] 認証局が失効した場合への対応方法を追加
