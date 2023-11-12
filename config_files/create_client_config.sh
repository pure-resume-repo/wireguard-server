#!/bin/bash

# Generate the private and public keys
private_key=$(wg genkey)
public_key=$(echo "${private_key}" | wg pubkey)

# Generate a pre-shared key
preshared_key=$(wg genpsk)

# Print the generated public key
echo "Generated Public Key: ${public_key}"

# Create the configuration file
cat > wg1-client.conf <<EOL
[Interface]
PrivateKey = ${private_key}
ListenPort = 51820
Address = 10.0.0.2/32
#DNS = 8.8.8.8, 8.8.4.4

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = SERVER_IP:51820
PresharedKey = ${preshared_key}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOL

# Inform the user
echo "Configuration saved to wg1-client.conf with placeholder 'SERVER_PUBLIC_KEY' for server's public key."
