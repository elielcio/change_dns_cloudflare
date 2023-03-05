#!/bin/bash

# Antes de rodar este script instale as extensões dig  e jd
# sudo apt install jq dnsutils

if [ -n "$1" ]; then
    RECORD_NAME="$1"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Não foi possível encontrar o ID do registro DNS para $RECORD_NAME"
    exit 1
fi


# Variáveis de autenticação da API Cloudflare
ACCOUNT_EMAIL="seu_email_cloudflare"
ZONE_NAME="dominio.com.br"
API_TOKEN="api_token_do_dominio"
RECORD_TYPE="A" #tipo de registro

# Obtenha o endereço IP atual da máquina
current_ip=$(curl -s https://api.ipify.org/)

# Obtenha o endereço IP registrado para o subdomínio especificado
dns_ip=$(dig +short $RECORD_NAME)

# Verifique se o endereço IP atual é diferente do endereço IP registrado
if [ "$current_ip" != "$dns_ip" ]; then
    
    # Obtenha o ID da zona a partir do nome da zona
    zone_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE_NAME" \
        -H "X-Auth-Email: $ACCOUNT_EMAIL" \
        -H "X-Auth-Key: $API_TOKEN" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')

    # Obtenha o ID do registro DNS a partir do nome do registro
    url_get_record="https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=$RECORD_TYPE&name=$RECORD_NAME"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - "$url_get_record

    record_id=$(curl -s -X GET "$url_get_record" \
         -H "X-Auth-Email: $ACCOUNT_EMAIL" \
        -H "X-Auth-Key: $API_TOKEN" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')

    # Verifique se o ID do registro DNS foi encontrado
    if [ -z "$record_id" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Não foi possível encontrar o ID do registro DNS para $RECORD_NAME"
    exit 1
    fi

    # Faça uma chamada à API Cloudflare para atualizar o registro DNS
    response=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
         -H "X-Auth-Email: $ACCOUNT_EMAIL" \
        -H "X-Auth-Key: $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"$RECORD_TYPE\",\"name\":\"$RECORD_NAME\",\"content\":\"$current_ip\",\"ttl\":120,\"proxied\":false}")

    # Verifique se a atualização do registro DNS foi bem sucedida
    if echo "$(date '+%Y-%m-%d %H:%M:%S') - $response" | grep -q "\"success\":false"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Não foi possível atualizar o registro DNS para $RECORD_NAME"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $response"
    exit 1
    fi

    # Imprima a resposta da API Cloudflare com o registro DNS atualizado
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Registro DNS atualizado para o endereço IP de $dns_ip para $current_ip"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $response"

#else
  #echo "$(date '+%Y-%m-%d %H:%M:%S') - O endereço IP atual $current_ip já está registrado para o subdomínio $RECORD_NAME"
fi

# Aguarde a entrada do usuário antes de terminar a execução
#read -p "Pressione Enter para continuar..."