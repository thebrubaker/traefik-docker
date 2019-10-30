openssl req -x509 -out test.crt -keyout test.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=test' -extensions EXT -config <( \
   printf "[dn]\nCN=test\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:test\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")