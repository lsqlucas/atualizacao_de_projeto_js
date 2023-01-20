#!/bin/bash
echo -e "\nEsse script copia os arquivos: \n -.next \n -package.json \n -pnpm-lock.yaml \n -public \n -.env.production \n -next.config.js \nDo repositorio onde esta o projeto node \nNa sequencia faz o processo de build e inicia o servidor js \n"
echo -e "\nInsira as informações do host remoto abaixo:"
read -p "IP: " IP
read -p "Usuario: " USER
read -s -p "Informe sua senha: " PASSWD
echo ""
read -p "Caminho ecommerce: " EC_PATH

caminho=/var/www/projetojs

mv $caminho /var/www/projetojs_bkp
mkdir $caminho

echo "Copiando .next..."
sshpass -p $PASSWD scp -r $USER@$IP:$EC_PATH/.next $caminho/
echo "Copiando package.json..."
sshpass -p $PASSWD scp -r $USER@$IP:$EC_PATH/package.json $caminho/
echo "Copiando pnpm-lock.yaml..."
sshpass -p $PASSWD scp -r $USER@$IP:$EC_PATH/pnpm-lock.yaml $caminho/
echo "Copiando public..."
sshpass -p $PASSWD scp -r $USER@$IP:$EC_PATH/public $caminho/
echo "Copiando .env.production..."
sshpass -p $PASSWD scp -r $USER@$IP:$EC_PATH/.env.production $caminho/
echo "Copiando next.config.js..."
sshpass -p $PASSWD scp -r $USER@$IP:$EC_PATH/next.config.js $caminho/

cd $caminho && pnpm i --production

cd $caminho && pnpm start
