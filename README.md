## Mudança automática de DNS no Cloudflare
Esse script permite automatizar a atualização de um registro DNS no Cloudflare para um determinado subdomínio de um domínio configurado nessa plataforma.

O script foi desenvolvido em Bash e utiliza a API do Cloudflare para obter e atualizar as informações do registro DNS.

## Pré-requisitos
Para utilizar este script, você precisará ter:

1. Acesso à uma conta na Cloudflare com um token de API válido.
2. O nome do registro DNS que você deseja atualizar.
3. As extensões dig e jq instaladas em sua máquina.

Você pode instalar as extensões digitando os seguintes comandos no terminal:

### Debian e Ubuntu
sudo apt install jq dnsutils

### CentOS e Red Hat Enterprise Linux
sudo yum install jq bind-utils

## Configuração
### Obtenção do Token da API na Cloudflare
Antes de executar o script, você precisa gerar um token de API na Cloudflare com as seguintes permissões:

Zone.Zone
Zone.DNS

Para obter um token, siga os passos abaixo:

1. Faça login em sua conta Cloudflare.
2. No canto superior direito, clique no seu perfil e selecione "My Profile".
3. Na aba "API Tokens", clique em "Create Token".
4. Insira um nome descritivo para o token, selecione as permissões necessárias e clique em "Create Token".
5. Copie o token gerado para utilizar no script.

Impotante! é altamente recomendado criar um token para cada um dos dominios (ZONES) de sua conta. Desta forma evita-se alterações indesejadas

## Configuração do Script
Antes de executar o script, você precisa editar algumas variáveis de acordo com sua configuração:

ACCOUNT_EMAIL: O e-mail cadastrado em sua conta Cloudflare.
ZONE_NAME: O nome da zona DNS que contém o registro a ser atualizado.
API_TOKEN: O token de API que você gerou na Cloudflare.
RECORD_NAME: O nome do registro DNS que você deseja atualizar.
RECORD_TYPE: O tipo do registro DNS (normalmente, A).

## Utilização
1. Clone o repositório: git clone https://github.com/elielcio/change-dns-cloudflare.git
2. Entre na pasta do repositório: cd change-dns-cloudflare
3. Abra o arquivo change_dns_cloudflare.sh e edite as variáveis de acordo com a sua conta Cloudflare: ACCOUNT_EMAIL, ZONE_NAME e API_TOKEN.
4. Salve o arquivo change_dns_cloudflare.sh na pasta /usr/local/scripts/ com o seguinte comando: sudo mv change_dns_cloudflare.sh /usr/local/scripts/
5. Tornar o arquivo executável: sudo chmod +x /usr/local/scripts/change_dns_cloudflare.sh
6. Voce pode chamar o comando diretamente pela linha de comando passando o subdominio como parametro. . /usr/local/scripts/change_dns_cloudflare.sh subdominio.dominio.com.br
7. Ou pode criar um job para executar de tempo em tempos. Faça da seguinte forma: Execute o comando. sudo crontab -e. Exemplo de chamada cron para atualizar o registro DNS a cada 30 minutos:
*/30 * * * * /usr/local/scripts/change_dns_cloudflare.sh subdominio.dominio.com.br >> /etc/logs/change_dns_cloudflare_EXEMPLO.log 2>&1
8.Salve e saia do arquivo. O script será executado automaticamente a cada 30 minutos e registrará um log na pasta /etc/logs/change_dns_cloudflare_EXEMPLO.log.