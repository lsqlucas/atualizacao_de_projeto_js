#!/bin/bash
#
#Autor: Lucas Queiroz
#Data: 19/05/2023
#Descrição: Script verifica se o projeto existe localmente, se não existir clona, se existir lista as opções do projeto
#			Primordialmente o script foi criado para automatizar a rotina de atualização dos projetos criados pela equipe de desenvolvimento web,
#			no entanto, se fez necessario incrementar funções adicionais. 
#			Abaixo as funções executadas pelo script:
#
#			Verifica pacotes necessarios para execução do projeto
#			Verifica pacotes necessarios para execução do projeto
#			Clonar Projeto
#			Excluir Projeto
#			Checkout
#			Compilar Projeto
#			Atualizar Projeto localmente
#			Atualizar Projeto nos servidores remotos de teste e web
#			Compila projeto no servidores remotos
#			Rollback de versão no servidor web
#
#
#Preparação:1 - Inclua seu usuario ao grupo de sudo
#				adduser usuario sudo 
#			2 - Crie um diretorio para armazenamento dos Projetos e cole o script dentro dessa pasta
#				mkdir Projetos 
#			3 - Conceda permissão de execução ao script na primeira vez que for executa-lo
#				sudo chmod +x atualizacao.sh
#			2 -	Execute o script
#				./atualizacao.sh
#
#
#Execução:	./atualizacao.sh
#
#
#######FUNÇÕES SEM PROCESSAMENTO#################################

function Anime2 ()
{
echo -e "\n"
echo ' ______     __  __     ______   ______     __    __     ______     ______   __     ______     ______    '
echo '/\  __ \   /\ \/\ \   /\__  _\ /\  __ \   /\ "-./  \   /\  __ \   /\__  _\ /\ \   /\___  \   /\  ___\   '
echo '\ \  __ \  \ \ \_\ \  \/_/\ \/ \ \ \/\ \  \ \ \-./\ \  \ \  __ \  \/_/\ \/ \ \ \  \/_/  /__  \ \  __\   '
echo ' \ \_\ \_\  \ \_____\    \ \_\  \ \_____\  \ \_\ \ \_\  \ \_\ \_\    \ \_\  \ \_\   /\_____\  \ \_____\ '
echo '  \/_/\/_/   \/_____/     \/_/   \/_____/   \/_/  \/_/   \/_/\/_/     \/_/   \/_/   \/_____/   \/_____/ '
echo -e "\n ------------------------------------------------------------------------------------------------------"
}

function Anime3 ()
{
echo '  __  _  _  ____  __  __  __   __  ____  __  ___  ___ '
echo ' (  )( )( )(_  _)/  \(  \/  ) (  )(_  _)(  )(_  )(  _)'
echo ' /__\ )()(   )( ( () ))    (  /__\  )(   )(  / /  ) _)'
echo '(_)(_)\__/  (__) \__/(_/\/\_)(_)(_)(__) (__)(___)(___)'
echo -e "\n ------------------------------------------------------"
}

#######FUNCOES BASICAS DO PROJETO######################################

function iniciar ()
{
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $script_dir

current_dir="$(pwd)"

if [[ "$current_dir" != "$script_dir" ]]; then
	script_name="$(basename "$0")"
    echo -e "Esse script só pode ser executado a partir do diretório $script_dir. \nPor favor acesse o diretorio e execute da seguinte forma: \nEx.: cd $script_dir \nEx.: ./$script_name"
    exit 1
fi
}

function checagem ()
{
if [ $? = 0 ]
then
	echo -e "\nConcluido [$?]\n------------------------------------------"
	ck=0
else
	echo -e "\nErro: [$?]\n------------------------------------------"
	ck=1
fi
}

function Anime1(){ 
    local i=2 
    while [[ ! -z $(ps | grep "$!") ]]; do  
        printf "[          ] Concluindo" | sed "s/ /\-\>/$i" 
        printf "\r" 
        sleep 0.03
        ((i++))
        if [ "$i" == 11 ]; then 
            for ((i;i>2;i--)); do 
                printf "[          ] Concluindo" | sed "s/ /\<\-/$i"
                printf "\r" 
                sleep 0.03
            done
        fi
    done

printf "[---😀😀---] Procedimento Concluido.\n"
}

function registro()
{
export DIA=`date +%Y%m%d`
export DAY=`date +%d/%m/%Y" - "%H:%M:%S`

echo "[$DAY] Projeto $projeto - branch $bch - atualizado no servidor $sev" >> ../log_atualizacao.log 
echo "[$DAY] Projeto $projeto - branch $bch - atualizado no servidor $sev"
}

function registro_server()
{
export DIA=`date +%Y%m%d`
export DAY=`date +%d/%m/%Y" - "%H:%M:%S`

sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP <<-EOF >/dev/null
echo "[$DAY] Projeto $projeto - branch $bch - atualizado no servidor $sev - Por $USER" >> /var/log/log_atualizacao.log
EOF
echo "Log Criado no Servidor $sev"
}

function registro_server_rollback()
{
export DIA=`date +%Y%m%d`
export DAY=`date +%d/%m/%Y" - "%H:%M:%S`

sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP <<-EOF >/dev/null
echo "[$DAY] Projeto $projeto - realizado o rollback no servidor $sev - Por $USER" >> /var/log/log_rollback.log
EOF
echo "Log Criado no Servidor $sev"
}

function pacotes()
{
E=0
packages=("git" "sshpass" "composer" "nodejs" "php8.1" "php8.1-opcache" "php8.1-sqlite3" "php8.1-common" "php8.1-curl" "php8.1-cli" "php8.1-mysql" "php8.1-intl" "php8.1-xml" "php8.1-mbstring" "php8.1-pgsql" "php8.1-readline" "php8.1-gd" "php8.1-interbase" "php8.1-cgi" "php8.1-decimal" "php8.1-dev" "php8.2" "php8.2-opcache" "php8.2-sqlite3" "php8.2-common" "php8.2-curl" "php8.2-cli" "php8.2-mysql" "php8.2-intl" "php8.2-xml" "php8.2-mbstring" "php8.2-pgsql" "php8.2-readline" "php8.2-gd" "php8.2-interbase" "php8.2-cgi" "php8.2-decimal" "php8.2-dev")
logsss="$PWD/log_update.log"
export dt=`date +%d/%m/%Y" - "%H:%M:%S`
echo -e "\nIniciando atualização de pacotes necessarios para Execução do script \nPara consultar o log consulte o arquivo $PWD/log_update.log \n\n$dt" | tee $logsss

for package in "${packages[@]}"; do
	echo -e "\nVerificando Pacote $package" | tee -a $logsss
    if dpkg -s "$package" >/dev/null 2>&1; then		
        echo -e "\nO pacote $package já está instalado. \n ..........................................................." | tee -a $logsss
    else
        echo "O pacote $package não está instalado. Atualizando e instalando..." | tee -a $logsss
		if [ $package == "php8.1" ] ; then
			echo -e "\nAdicionando repositorio PHP a source list" | tee -a $logsss
			echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list
			erroat
			echo -e "\n ATUALIZANDO REPOSITORIO"  | tee -a $logsss
			sudo apt-get update >> $logsss 2>&1
			erroat
			echo -e "\n ........................................................... \n IMPORTANDO CHAVES"  | tee -a $logsss
			importpubkey >> $logsss 2>&1
		fi

		echo -e "\n ATUALIZANDO REPOSITORIO"  | tee -a $logsss
        sudo apt-get update >> $logsss 2>&1
		echo -e "\n INSTALANDO PACOTE $package"  | tee -a $logsss
        sudo apt-get install -y "$package" >> $logsss 2>&1
		echo -e "\n ........................................................... \n PROCEDIMENTO CONCLUIDO \n\n"  | tee -a $logsss

		if [ $package = "nodejs" ] ; then
			echo "\n INSTALANDO PACOTE CURL"  | tee -a $logsss
			sudo apt-get install curl >> $logsss 2>&1
			echo -e "\n ........................................................... \n INSTALANDO PACOTE $package"  | tee -a $logsss
			curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >> $logsss 2>&1
			sudo apt-get install -y nodejs >> $logsss 2>&1
			echo -e "\n ........................................................... \n INSTALANDO NPM"  | tee -a $logsss
			echo "É NECESSARIO INSTALAR O PACOTE PNPM"
			sudo npm install npm@latest -g >> $logsss 2>&1
			erroat
			echo -e "\n ........................................................... \n INSTALANDO PNPM"  | tee -a $logsss
			sudo npm install -g pnpm >> $logsss 2>&1
			erroat
		fi
    fi
	echo "_____________________________________________________________" | tee -a $logsss
done
echo -e "\n Alternando versão do PHP para a versão 8.1"  | tee -a $logsss
sudo update-alternatives --set php /usr/bin/php8.1 | tee -a $logsss
composerup
echo -e "\n Atualizando pnpm"  | tee -a $logsss
curl -fsSL https://get.pnpm.io/install.sh | sh - | tee -a $logsss
echo "------------------------------------------------------------------------------------"  | tee -a $logsss
clear
echo -e "\nAtualizações Concluidas [$E]"  | tee -a $logsss
if [ $E != 0 ]
then
echo -e "\n Verifique o arquivo $PWD/log_update.log para checar se houve falhas. \n\nSUGIRO VERIFICAR....😀😀"
fi
}

function importpubkey ()
{
	sudo apt update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p' | while read key; do if ! [[ ${keys[*]} =~ "$key" ]]; then sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$key"; keys+=("$key"); fi; done
	erroat
}

function erroat ()
{
	if [ $? != 0 ]
	then
	E+=1
	fi
}

function composerup ()
{
	echo -e "\n Atualizando composer"  | tee -a $logsss
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" | tee -a $logsss
	erroat
	php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" | tee -a $logsss
	erroat
	php composer-setup.php | tee -a $logsss
	erroat
	php -r "unlink('composer-setup.php');" | tee -a $logsss
	erroat
	sudo composer self-update | tee -a $logsss
	erroat
}

#######################################################
##########FUNÇÕES PROCESSAMENTO CLIENTE###############

function inicio ()
{
atualizaveis="api_cobrancas:api_dashboardrh:api_entregas:api_prevendas:api_quadroavisos:bordero:empresa_store:ecommerce:web_entregas:web_biblioteca:web-contasapagar-api-v1:web_hostFinanceiro:web_institucional:web_intranet:web_suporte:web_vagas:web-gateway-hooks-api-v1:ecommerce_adm:web-ecommerce-admin-back-v1:web-contasapagar-front-v1:web-ecommercebackend-api-v1:web-empresa-bikes-front-v1:web-imguploader-api-v1:web-emailsender-api-v1"
pjs=ls
Anime2
echo "OBS: Caso o projeto não exista no seu repositorio local, basta digitar o nome do projeto para clonar..."
echo -e "\n"
echo -e "\nPROJETOS ATUALIZAVEIS: \n"
echo $atualizaveis  | tr ':' '\n' | tr 'a-z' 'A-Z' | column
echo -e "\n"
read -e -p "Insira o nome do projeto que deseja atualizar ou clonar: " PJ

if [ -z "$PJ" ] 
then
echo "Informação invalida.. É necessario informar o nome de um projeto"
exit
fi

if [ $PJ = "web_hostFinanceiro" ] || [ $PJ = "web_hostFinanceiro/" ]
then
PJ=$(echo $PJ)
else
PJ=$(echo $PJ | tr 'A-Z' 'a-z')
fi

executa
}

function executa ()
{
barra=$(echo $PJ | rev | cut -c 1 | rev)
sair=0

if [ $barra = "/" ]
then
	#Existe barra!!!
	ler=$(echo $PJ | rev | cut -c2- | rev)
	if $pjs | grep $ler >/dev/null
	then
		projeto=$ler
		autorizado
		cd $projeto || exit 
		caminho=$(pwd)
		#passar
		menu
		sleep 2 & Anime1
		registro
	else
		projeto=$PJ
		echo -e "\nprojeto não existe localmente...🤔"
		baixar
	fi
	
else
	#Não existe barra!!!
	if $pjs | grep $PJ >/dev/null
	then
		projeto=$PJ
		autorizado
		cd $projeto || exit
		caminho=$(pwd)
        #passar
		menu
		sleep 2 & Anime1
		registro
    else
		projeto=$PJ
		echo -e "\nprojeto não existe localmente...🤔"
		baixar
	fi

fi
}

function baixar () 
{
echo -e "\n"
read -p "Deseja clonar o projeto $projeto ? [sim/nao]" opc2
case $opc2 in
"sim")
		clonarpjt
		if [ $ck != 0 ]
		then
		echo "Tente novamente!!!"
		else
		cd ..
		fi
		inicio
		;;
"SIM")
		clonarpjt
		if [ $ck != 0 ]
		then
		echo "Tente novamente!!!"
		else
		cd ..
		fi
		inicio
		;;
"Sim")
		clonarpjt
		if [ $ck != 0 ]
		then
		echo "Tente novamente!!!"
		else
		cd ..
		fi
		inicio
		;;
"S")
		clonarpjt
		if [ $ck != 0 ]
		then
		echo "Tente novamente!!!"
		else
		cd ..
		fi
		inicio
		;;
"Yes")
		clonarpjt
		if [ $ck != 0 ]
		then
		echo "Tente novamente!!!"
		else
		cd ..
		fi
		inicio
		;;
"Y")
		clonarpjt
		if [ $ck != 0 ]
		then
		echo "Tente novamente!!!"
		else
		cd ..
		fi
		inicio
		;;
"")
		clonarpjt
		if [ $ck != 0 ]
		then
		echo "Tente novamente!!!"
		else
		cd ..
		fi
		inicio
		;;
*)
        echo -e "\nProjeto não clonado \nEncerrando aplicação..."
		sleep 2
		sair=1
        ;;
esac
}

function autorizado()
{
case $projeto in

"api_cobrancas")
		website="dev.apicobranca.empresa.teste.com"
		;;
"api_dashboardrh")
		website="apidashboardrh.empresa.teste.com"
        ;;
"api_dashboard")
		website="dashboard.empresa.teste.com"
		;;
"api_entregas")
		website="apientregas.empresa.teste.com"
		;;
"api_prevendas")
		website="api.prevendas.teste.com"
        ;;
"api_quadroavisos")
		website="dev.apiquadroavisos.empresa.teste.com"
        ;;
"api_suporte")
		website="apisuporte.empresa.teste.com"
        ;;
"bordero")
		website="bordero.empresa.teste.com"
        ;;
"empresa_store")
		website="empresastore.empresa.teste.com"
        ;;
"ecommerce")
		website="dev.ecommerce.empresa.teste.com"
		clear
        echo -e "\nEM DESENVOLVIMENTO"
		echo -e "\n------------------------------------------------------------------------- \n"
		inicio
        ;;
"web_entregas")
		website="entregas.empresa.teste.com"
        ;;
"web_biblioteca")
		website="biblioteca.empresa.teste.com"
        ;;
"web-contasapagar-api-v1")
		website="apicontasapagar.empresa.teste.com"
        ;;
"web_hostFinanceiro")
		website="hostfinanceiro.empresa.teste.com"
        ;;
"web_institucional")
		website="institucional.empresa.teste.com"
        ;;
"web_intranet")
		website="intranet.empresa.teste.com"
        ;;
"web_suporte")
		website="suporte.empresa.teste.com"
        ;;
"web_vagas")
		website="vagas.empresa.teste.com"
        ;;
"web-gateway-hooks-api-v1")
		website="api.gatewayhooks.empresa.teste.com"
        ;;
"ecommerce_adm")
		website="admbikes.empresa.teste.com"
		;;
"web-ecommerce-admin-back-v1")
		website="api-admbikes.empresa.teste.com"
		;;
"web-ecommercebackend-api-v1")
		website="api-empresabikes.empresa.teste.com"
		;;
"web-empresa-bikes-front-v1")
		website="empresabikes.empresa.teste.com"
		;;
"web-imguploader-api-v1")
		website="apiimgbikes.empresa.teste.com"
		;;
"web-emailsender-api-v1")
		website="api.sender.empresa.teste.com"
		;;
"web-contasapagar-front-v1")
		website="contasapagar.empresa.teste.com"
		;;
*)
	clear
	echo -e "\n Opção invalida.🤔"
	echo -e "\n------------------------------------------------------------------------- \n"
	inicio
	;;
esac
}

function menu ()
{
OPC=""
echo -e "\n"
echo -e "\n1 -> Fazer Checkout (Alternar Branch) \n2 -> Atualizar $projeto localmente (pull, build) \n3 -> Atualizar $projeto no servidor de TESTE \n4 -> Atualizar $projeto no servidor WEB \n5 -> Excluir $projeto localmente e clonar novamente \n6 -> ATUALIZAÇÃO COMPLETA DO $projeto (pull -> build -> atualiza no server teste -> atualiza webserver) \n7 -> ROLLBACK DE VERSÃO NO SERVIDOR WEB \n8 -> EXCLUIR PROJETO $projeto LOCALMENTE E SAIR \n9 -> SAIR \n" | tr 'a-z' 'A-Z'
read -p "Digite a opção desejada: " OPC

case $OPC in
"1")
        checkoutgit
		menu
        ;;
"2")
        atualiza
		excecaoup2	
		menu
         ;;
"3")
		excecaoup2
        echo -e "\nAtualizando no Servidor de teste..."
		sleep 2
        serverteste
		menu
         ;;
"4")
		excecaoup
		echo -e "\nBuscando Servidores WEB..."
		sleep 2
        server
         ;;
"5")
        excluirpjt
		if [ $ck != 0 ]
		then
			echo -e "\nErro na exclusão"
		else
			echo -e "\nProjeto excluido com sucesso"
			cloneckeck
		fi
		menu
         ;;
"6")
		echo -e "\nIniciando atualização completa..."
        atualiza
		excecaoup2
		echo -e "\nAtualizando no Servidor de teste..."
		sleep 2
		serverteste
		excecaoup
		echo -e "\nBuscando Servidores WEB..."
		sleep 2
        server
         ;;
"7")    retornaversao
		menu
         ;;
"8")
        excluirpjt
		if [ $ck != 0 ]
		then
		echo -e "\nErro na exclusão"
		menu
		else
		echo -e "\nProjeto excluido com sucesso"
		sleep 2 & Anime1
		exit
		fi
        ;;
"9")
		sleep 2 & Anime1
        exit
         ;;
"")
		echo -e "\nIniciando atualização completa..."
        atualiza
		excecaoup2
		echo -e "\nAtualizando no Servidor de teste..."
		sleep 2
		serverteste
		excecaoup
		echo -e "\nBuscando Servidores WEB..."
		sleep 2
        server
         ;;
*)
        echo -e "\n Opção Invalida.🤔 \nSelecione uma opção de 1 a 9"
		echo -e "\n------------------------------------------------------------------------- \n"
		menu
        ;;
esac
}

function cloneckeck () 
{
clonarpjt
if [ $ck != 0 ]
then
	cloneckeck
else
	checkoutgit
	echo -e "\nExito no checkout"
fi
}

function atualiza()
{
case $projeto in

"api_cobrancas")
        updategit
        ;;
"api_dashboardrh")
        updategit
        ;;
"api_dashboard")
        updategit
        ;;
"api_entregas")
        updategit
        ;;
"api_prevendas")
        updategit
        ;;
"api_quadroavisos")
        updategit
        ;;
"api_suporte")
        updategit
        ;;
"bordero")
        updategit
        ;;
"empresa_store")
        updategit
        ;;
"ecommerce")
        updategit
        ;;
"web_entregas")
        updategit
        ;;
"web_biblioteca")
        updategit
        ;;
"web-contasapagar-api-v1")
        updategit
        ;;
"web_hostFinanceiro")
		updategit
		vendor
        ;;
"web_institucional")
        updategit
        ;;
"web_intranet")
        updategit
        ;;
"web_suporte")
        updategit
        ;;
"web_vagas")
        updategit
        ;;
"web-gateway-hooks-api-v1")
        updategit
        ;;
"ecommerce_adm")
	updategit
	;;
"web-ecommerce-admin-back-v1")
	updategit
	vendor
	;;
"web-ecommercebackend-api-v1")
	updategit
	vendor
	;;
"web-empresa-bikes-front-v1")
	updategit
	;;
"web-imguploader-api-v1")
	updategit
	vendor
	;;
"web-emailsender-api-v1")
	updategit
	vendor
	;;
"web-contasapagar-front-v1")
	updategit
	echo -e "\nInstalando dependencias"
	pnpm i
	checagem
	echo -e "\nRemovendo dist..."
	rm -r dist_bkp >/dev/null
	mv dist/ dist_bkp/
	checagem
	echo -e "\nBUILD:"
	pnpm build
	checagem
	;;
*)
	clear
	echo -e "\n Projeto não existe ou não foi desenvolvida rotina de atualização.🤔"
	echo -e "\n------------------------------------------------------------------------- \n"
	inicio
	;;
esac
}

function excecaoup ()
{
	if [ $projeto = "web-empresa-bikes-front-v1" ]
	then
		echo -e "\nInstalando dependencias"
		pnpm i
		checagem
		echo -e "\nBUILD:"
		pnpm build
		checagem
	fi
	if [ $projeto = "ecommerce_adm" ]
	then
		sed -i 's/teste/gerais/g' .env.production
		checagem
		echo -e "\nInstalando dependencias"
		pnpm i
		checagem
		echo -e "\nRemovendo dist..."
		rm -r dist_bkp >/dev/null
		mv dist/ dist_bkp/
		checagem
		echo -e "\nBUILD:"
		pnpm build
		checagem
	fi
}

function excecaoup2 ()
{
	if [ $projeto = "web-empresa-bikes-front-v1" ]
	then
		echo -e "\nInstalando dependencias"
		pnpm i
		checagem
		echo -e "\nBUILD TESTE:"
		pnpm build:staging
		checagem
	fi
	if [ $projeto = "ecommerce_adm" ]
	then
		sed -i 's/gerais/teste/g' .env.production
		checagem
		echo -e "\nInstalando dependencias"
		pnpm i
		checagem
		echo -e "\nRemovendo dist..."
		rm -r dist_bkp >/dev/null
		mv dist/ dist_bkp/
		checagem
		echo -e "\nBUILD:"
		pnpm build
		checagem
	fi
}

function updategit ()
{

brts=$( git branch -r | rev | cut -d "/" -f1 | rev )
echo -e "\nBranches disponiveis nesse projeto: \n$brts"
echo -e "\n"
read -e -p "Insira o nome da branch a ser atualizada: " bch
echo -e "\n-----------------------------------------------------------------"

echo -e "\nAtualizando repositorio"
git pull origin $bch

if [ $? != 0 ] 
then
erropjt
fi

checagem
}

function checkoutgit ()
{
brts2=$( git branch -r | rev | cut -d "/" -f1 | rev )
echo -e "\nBranches disponiveis nesse projeto: \n$brts2"
echo -e "\n"
read -e -p "Insira o nome da branch para a qual deseja alternar: " bch2
echo -e "\n-----------------------------------------------------------------"

echo -e "\ngit checkout $bch2"
git checkout $bch2
checagem
}

function excluirpjt ()
{
cd ..
echo -e "\n Excluindo projeto $projeto localmente"
echo -e "\n Insira a sua senha de sudo local para remover o projeto"
sudo rm -r $projeto
checagem
}

function clonarpjt ()
{
echo -e "\n Clonando projeto $projeto localmente"
echo -e "\n Insira a sua senha do servidor de versionamento departamental (192.168.2.176):"
git clone $USER@192.168.2.176:/srv/versionamento/git/$projeto
checagem
if [ $ck != 0 ]
then
echo -e "\nFalha ao clonar o projeto!"
else
echo -e "\nProjeto clonado com sucesso..."
cd $projeto || exit
fi
}


function erropjt ()
{
echo -e "\n"
echo -e "\nERRO na atualização da branch!!!! \n"
read -p "Deseja remover o projeto $projeto e clonar novamente? [sim/nao]" opc1
case $opc1 in
"sim")
        excluirpjt
		if [ $ck != 0 ]
		then
			echo -e "\nErro na exclusão"
		else
			echo -e "\nProjeto excluido com sucesso"
			clonarpjt
			echo -e "\nProjeto clonado com sucesso"
			checkoutgit
			echo -e "\nExito no checkout"
		fi
		;;
"SIM")
        excluirpjt
		if [ $ck != 0 ]
		then
			echo -e "\nErro na exclusão"
		else
			echo -e "\nProjeto excluido com sucesso"
			clonarpjt
			echo -e "\nProjeto clonado com sucesso"
			checkoutgit
			echo -e "\nExito no checkout"
		fi
        ;;
"Sim")
        excluirpjt
		if [ $ck != 0 ]
		then
			echo -e "\nErro na exclusão"
		else
			echo -e "\nProjeto excluido com sucesso"
			clonarpjt
			echo -e "\nProjeto clonado com sucesso"
			checkoutgit
			echo -e "\nExito no checkout"
		fi
        ;;
"S")
        excluirpjt
		if [ $ck != 0 ]
		then
			echo -e "\nErro na exclusão"
		else
			echo -e "\nProjeto excluido com sucesso"
			clonarpjt
			echo -e "\nProjeto clonado com sucesso"
			checkoutgit
			echo -e "\nExito no checkout"
		fi
        ;;
"Yes")
        excluirpjt
		if [ $ck != 0 ]
		then
			echo -e "\nErro na exclusão"
		else
			echo -e "\nProjeto excluido com sucesso"
			clonarpjt
			echo -e "\nProjeto clonado com sucesso"
			checkoutgit
			echo -e "\nExito no checkout"
		fi
        ;;
"Y")
        excluirpjt
		if [ $ck != 0 ]
		then
			echo -e "\nErro na exclusão"
		else
			echo -e "\nProjeto excluido com sucesso"
			clonarpjt
			echo -e "\nProjeto clonado com sucesso"
			checkoutgit
			echo -e "\nExito no checkout"
		fi
        ;;
"")
        excluirpjt
		if [ $ck != 0 ]
		then
			echo -e "\nErro na exclusão"
		else
			echo -e "\nProjeto excluido com sucesso"
			clonarpjt
			echo -e "\nProjeto clonado com sucesso"
			checkoutgit
			echo -e "\nExito no checkout"
		fi
        ;;
*)
        echo -e "\nNenhuma modificação feita \nVerifique o motivo do erro no projeto..."
		sleep 2
        ;;
esac
}


function vendor ()
{
check1=ls
echo -e "\nInstalando dependencias"
if $check1 | grep "vendor" >/dev/null
then
	echo -e "\nAs dependencias do projeto $projeto já estão instaladas"
    rmvendor
	check2=ls
	if $check2 | grep "vendor" >/dev/null
	then
		echo -e "\nAs dependencias do projeto $projeto já existentes foram mantidas"
	else
		uservendor
		sleep 2
		composer i --no-dev
		echo -e "\nAs dependencias do projeto $projeto foram atualizadas"
	fi
	checagem
else
	uservendor
	sleep 2
    composer i --no-dev
    echo -e "\nAs dependencias do projeto $projeto foram atualizadas"
	checagem
fi
}

function rmvendor ()
{
echo -e "\n"
read -p "Deseja remover o vendor do projeto $projeto para atualizar as dependencias?[sim/nao]: " vdsim
case $vdsim in
"sim")
        rmvd
        ;;
"SIM")
        rmvd
         ;;
"Sim")
        rmvd
         ;;
"S")
        rmvd
         ;;
"Yes")
        rmvd
         ;;
"Y")
        rmvd
         ;;
"")
        rmvd
         ;;
*)
        echo -e "\nVendor não removido.."
        ;;
esac
}

function rmvd () 
{
sudo rm -r vendor
}

function uservendor () 
{
srcjson=$( find composer.json -name "composer.json" -type f -exec grep -HTn "@192.168.2.176" {} \; | cut -d ":" -f4 | cut -d "@" -f1 | cut -d '"' -f2 2>/dev/null)
srclock=$( find composer.lock -name "composer.lock" -type f -exec grep -HTn "@192.168.2.176" {} \; | cut -d ":" -f4 | cut -d "@" -f1 | cut -d '"' -f2 2>/dev/null)
rowjson=$( find composer.json -name "composer.json" -type f -exec grep -HTn "@192.168.2.176" {} \; | cut -d ":" -f2 2>/dev/null)
rowlock=$( find composer.lock -name "composer.lock" -type f -exec grep -HTn "@192.168.2.176" {} \; | cut -d ":" -f2 2>/dev/null)
ocorrenciajson=$( find composer.json -name "composer.json" -type f -exec grep -HTn "@192.168.2.176" {} \; | cut -d '"' -f4 2>/dev/null)
ocorrencialock=$( find composer.lock -name "composer.lock" -type f -exec grep -HTn "@192.168.2.176" {} \; | cut -d '"' -f4 2>/dev/null)

if  [ $srcjson = "andre" ] || [ $srclock = "philipe" ] 
then
	echo -e "\nO arquivo $projeto/composer.lock esta com o usuario $srclock \nAltere o usuario $srclock na ocorrencia $ocorrencialock (linha: $rowlock), para seu usuario no servidor departamental \nOu acione o programador $srclock  para que ele coloque a senha de atualização do projeto $projeto:"
	echo -e "\nO arquivo $projeto/composer.json esta com o usuario $srcjson \nAltere o usuario $srcjson na ocorrencia $ocorrenciajson (linha: $rowjson), para seu usuario no servidor departamental \nOu acione o programador $srcjson  para que ele coloque a senha de atualização do projeto $projeto:" 
else
	echo -e "\nUsuario $projeto/composer.lock: $srclock"
	echo -e "\nUsuario $projeto/composer.json: $srcjson"
fi
}

###########################################################################################
##########FUNÇÕES PROCESSAMENTO SERVIDOR###############

function serverteste ()
{
	IP="192.168.2.25"
    sev="SERVER TESTE(SERVERNODE)"
	caminhoremoto="/var/www/$projeto"
    caminhoremotobkp="/var/www/"$projeto"_bkp"
	USUARIO="root"
	PASS="AsF!@s*88pym"
	logout1="../log.out"
	sleep 2 & echo -e "\nVerificando acesso.."
	> "$logout1"
	sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP 'echo "Acesso OK"' 2>../log.out
	acess=$( cat ../log.out)
	at=$?
	checagem
	echo $acess
		if grep -q "denied" "$logout1" || grep -q "refused" "$logout1" 
		then
			echo "Senha incorreta"
			senha
		else
			echo "Senha correta"
			
			if [ $projeto = "web-empresa-bikes-front-v1" ]
        	then
				echo -e "\nProcesso de backup iniciado..."
				sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
				rm -r $caminhoremotobkp
				mv $caminhoremoto $caminhoremotobkp
				mkdir $caminhoremoto
				EOF
				checagem
			
				echo "Copiando package.json para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/package.json $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando pnpm-lock.yaml para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/pnpm-lock.yaml $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando public para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/public $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando .env.production para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/.env.production $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando .env.local do projeto anterior para $caminhoremoto..."
				sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
				cp $caminhoremotobkp/.env.local $caminhoremoto/
				EOF
				checagem
                                echo "Copiando .env.local do projeto na maquina para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/.env.production.local $USUARIO@$IP:$caminhoremoto/.env.local
				checagem
                                echo "Copiando next.config.mjs para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/next.config.mjs $USUARIO@$IP:$caminhoremoto/
				checagem
				echo -e "\nCopiando .next para $caminhoremoto..."
                sshpass -p $PASS scp -r $caminho/.next $USUARIO@$IP:$caminhoremoto/
                checagem
				sleep 2
                echo "Instalando Atualizações"
				sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF
				pm2 stop web-empresa-bikes-front-v1
				curl -fsSL https://get.pnpm.io/install.sh | sh -				
				source /root/.bashrc
				cd $caminhoremoto
				pnpm i --production
				pm2 start web-empresa-bikes-front-v1
				pm2 save
				EOF
				checagem

			elif [ $projeto = "ecommerce_adm" ]
			then
				ecadmup

				echo -e "\nReiniciando Apache2"
				sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl restart apache2'
				checagem
				echo -e "\nVerificando Status Apache2 \n"
				sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl status apache2'
				checagem
			else
				echo -e "\n \nMovendo $projeto..."
				sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
				rm -r $caminhoremotobkp
				mv $caminhoremoto $caminhoremotobkp
				EOF
				checagem
				echo -e "\n \nCopiando $projeto...."
				sshpass -p $PASS scp -r $caminho/ $USUARIO@$IP:$caminhoremoto/
				checagem
				excessoes
				copiaenv
				copiaht
				if [ $projeto = "web_hostFinanceiro" ]
				then
					echo -e "Copiando app.js"
					sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'cp /var/www/web_hostFinanceiro_bkp/Public/assets/js/app.js /var/www/web_hostFinanceiro/Public/assets/js/'
					checagem
				fi
				echo -e "\nReiniciando Apache2"
				sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl restart apache2'
				checagem
				echo -e "\nVerificando Status Apache2 \n"
				sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl status apache2'
				checagem
			fi
			registro_server
			echo -e "\nServidor de teste atualizado. \nO projeto $projeto esta disponivel a partir da URL: $website \nTeste e na sequencia atualize no respectivo servidor de produção."
			firefox --private-window $website 2>/dev/null &
		fi
	
}

###########################################################################################
##########FUNÇÕES PROCESSAMENTO SERVIDOR###############

function server ()
{

echo -e "\n-----------------------------------------------------------------"
echo "" > ../log.out
logout1="../log.out"
caminho=$(pwd)
USUARIO=""
OP=""
PASS=""
Anime3
echo -e "\n1 -> 192.168.2.15 - WONG(PROXY) \n2 -> 192.168.2.22 - FITZ(NODE1) \n3 -> 192.168.2.23 - SIMMONS(NODE2) \n4 -> 192.168.2.18 - SHU(WEBSERVER-1) \n5 -> 192.168.2.188 - QUILL(WEBSERVER-2)\n"
read -p "Digite a opção que corresponde ao servidor onde deseja atualizar o projeto $projeto: " OP
read -p "Digite o usuario do servidor: " USUARIO
read -s -p "Digite a senha: " PASS
echo -e "\n"

if [ -z "$PASS" ] 
then 
PASS="1"
fi

if [ -z "$USUARIO" ] 
then 
USUARIO="root"
fi

server2
}

function server2 ()
{
case $OP in

"1")
	IP="192.168.2.15"
	sev="WONG(PROXY)"
	checagem
	echo -e "\nATUALMENTE ESSE SERVIDOR NÃO POSSUI PROJETOS, APENAS REALIZA O ENCAMINHAMENTO DE REQUISIÇÕES DE PROXY REVERSO. \nSelecione outro server... \n"
	server
	;;
"2")
	echo "__________________________________________________________________________"
	IP="192.168.2.22"
        sev="FITZ(SERVERNODE-1)"
	caminhoremoto="/var/www/$projeto"
    caminhoremotobkp="/var/www/"$projeto"_bkp"
	if [ $projeto = "web-empresa-bikes-front-v1" ]
	then
		sleep 2 & echo -e "\nVerificando acesso.."
		> "$logout1"
		sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP 'echo "Acesso OK"' 2>../log.out
		acess=$( cat ../log.out)
		at=$?
		checagem
		echo $acess
		if grep -q "denied" "$logout1" || grep -q "refused" "$logout1" 
		then
			echo "Senha incorreta"
			senha
		else
			echo "Senha correta"
			echo -e "\nProcesso de backup iniciado..."
			sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
			rm -r $caminhoremotobkp
			mv $caminhoremoto $caminhoremotobkp
			mkdir $caminhoremoto
			EOF
			checagem
			if [ $projeto = "web-empresa-bikes-front-v1" ]
        		then
				echo "Copiando package.json para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/package.json $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando pnpm-lock.yaml para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/pnpm-lock.yaml $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando public para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/public $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando .env.production para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/.env.production $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando next.config.mjs para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/next.config.mjs $USUARIO@$IP:$caminhoremoto/
				checagem
				echo -e "\nCopiando .next para $caminhoremoto..."
                                sshpass -p $PASS scp -r $caminho/.next $USUARIO@$IP:$caminhoremoto/
                                checagem
				sleep 2
                                echo "Instalando Atualizações"
				sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF
				pm2 stop web-empresa-bikes-front-v1
				curl -fsSL https://get.pnpm.io/install.sh | sh -				
				source /root/.bashrc
				cd $caminhoremoto
				pnpm i --production
				pm2 start web-empresa-bikes-front-v1
				pm2 save
				EOF
				checagem
			fi
			registro_server
		fi
	else 
		echo -e "\nEsse projeto não pode ser atualizado nesse servidor. Por favor escolha outro server."
		server
	fi
	;;
"3")
	echo "__________________________________________________________________________"
	IP="192.168.2.23"
    sev="SIMMONS(SERVERNODE-2)"
	caminhoremoto="/var/www/$projeto"
    caminhoremotobkp="/var/www/"$projeto"_bkp"
	if [ $projeto = "web-empresa-bikes-front-v1" ]
	then
		sleep 2 & echo -e "\nVerificando acesso.."
		> "$logout1"
		sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP 'echo "Acesso OK"' 2>../log.out
		acess=$( cat ../log.out)
		at=$?
		checagem
		echo $acess
		if grep -q "denied" "$logout1" || grep -q "refused" "$logout1" 
		then
			echo "Senha incorreta"
			senha
		else
			echo "Senha correta"
			echo -e "\nProcesso de backup iniciado..."
			sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
			rm -r $caminhoremotobkp
			mv $caminhoremoto $caminhoremotobkp
			mkdir $caminhoremoto
			EOF
			checagem
			if [ $projeto = "web-empresa-bikes-front-v1" ]
        		then
				echo "Copiando package.json para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/package.json $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando pnpm-lock.yaml para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/pnpm-lock.yaml $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando public para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/public $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando .env.production para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/.env.production $USUARIO@$IP:$caminhoremoto/
				checagem
                                echo "Copiando next.config.mjs para $caminhoremoto..."
				sshpass -p $PASS scp -r $caminho/next.config.mjs $USUARIO@$IP:$caminhoremoto/
				checagem
				echo -e "\nCopiando .next para $caminhoremoto..."
                                sshpass -p $PASS scp -r $caminho/.next $USUARIO@$IP:$caminhoremoto/
                                checagem
				sleep 2
                                echo "Instalando Atualizações"
				sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF
				pm2 stop web-empresa-bikes-front-v1
				curl -fsSL https://get.pnpm.io/install.sh | sh -				
				source /root/.bashrc
				cd $caminhoremoto
				pnpm i --production
				pm2 start web-empresa-bikes-front-v1
				pm2 save
				EOF
				checagem
			fi
			registro_server
		fi
	else 
		echo -e "\nEsse projeto não pode ser atualizado nesse servidor. Por favor escolha outro server."
		server
	fi
	;;
"4")
	echo "__________________________________________________________________________"
        IP="192.168.2.18"
        sev="SHU(WEBSERVER-1)"
		caminhoremoto="/var/www/$projeto"
        caminhoremotobkp="/var/www/"$projeto"_bkp"
		if [ $projeto != "web-empresa-bikes-front-v1" ]
		then		
			sleep 2 & echo -e "\nVerificando acesso.."
			> "$logout1"
			sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP 'echo "Acesso OK"' 2>../log.out
			acess=$( cat ../log.out)
			at=$?
			checagem
			echo $acess
			if grep -q "denied" "$logout1" || grep -q "refused" "$logout1" 
			then
				echo "Senha incorreta"
				senha
			else
				echo "Senha correta"
			
				if [ $projeto = "ecommerce_adm" ]
				then
					ecadmup
				else
					echo -e "\n \nMovendo $projeto..."
					sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
					rm -r $caminhoremotobkp
						mv $caminhoremoto $caminhoremotobkp
					EOF
					checagem
					echo -e "\n \nCopiando $projeto...."
						sshpass -p $PASS scp -r $caminho/ $USUARIO@$IP:$caminhoremoto/
					checagem
					excessoes
					copiaenv
					copiaht
				fi
				echo -e "\nReiniciando Apache2"
				sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl restart apache2'
				checagem
				echo -e "\nVerificando Status Apache2 \n"
				sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl status apache2'
				checagem
				registro_server
			fi
		else
			echo -e "\nEsse projeto não pode ser atualizado nesse servidor. Por favor escolha outro server."
			server
		fi
	;;
"5")
	echo "__________________________________________________________________________"
        IP="192.168.2.188"
        sev="QUILL(WEBSERVER-2)"
		caminhoremoto="/var/www/$projeto"
        caminhoremotobkp="/var/www/"$projeto"_bkp"
		if [ $projeto != "web-empresa-bikes-front-v1" ]
		then
		
		sleep 2 & echo -e "\nVerificando acesso.."
		> "$logout1"
		sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP 'echo "Acesso OK"' 2>../log.out
		acess=$( cat ../log.out)
		at=$?
		checagem
		echo $acess
		if grep -q "denied" "$logout1" || grep -q "refused" "$logout1" 
		then
			echo "Senha incorreta"
			senha
		else
			echo "Senha correta"
			
	    if [ $projeto = "ecommerce_adm" ]
		then
			ecadmup
		else
			echo -e "\n \nMovendo $projeto..."
			sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
			rm -r $caminhoremotobkp
        	mv $caminhoremoto $caminhoremotobkp
			EOF
			checagem
			echo -e "\n \nCopiando $projeto...."
        	sshpass -p $PASS scp -r $caminho/ $USUARIO@$IP:$caminhoremoto/
			checagem
			excessoes
			copiaenv
			copiaht
		fi
		echo -e "\nReiniciando Apache2"
		sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl restart apache2'
		checagem
		echo -e "\nVerificando Status Apache2 \n"
		sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl status apache2'
		checagem
		registro_server
		fi
		else
			echo -e "\nEsse projeto não pode ser atualizado nesse servidor. Por favor escolha outro server."
			server
		fi
	;;
*)
	echo -e "Opção invalida...🤔 \nTente novamente!!!"
	server
	;;
esac
}

function senha ()
{
checagem
pswd=$(echo $PASS | tr 'AsF!@s*' '*')
echo -e "\nSenha incorreta!! \nTente Novamente \noperação: $OP, IP: $IP,USUARIO: $USUARIO, PASS: $pswd [$at]"
echo "" > ../log.out
server
}

function excessoes ()
{
if [ $projeto = "web_hostFinanceiro" ]
then
	echo -e "Copiando Sessões"
	sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'cp -r /var/www/web_hostFinanceiro_bkp/App/Session/ /var/www/web_hostFinanceiro/App/'
       	checagem
	echo -e "Concedendo permissão 777 para as Sessões"
        sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'chmod -R 777 /var/www/web_hostFinanceiro/App/Session/'
        checagem
	echo -e "Concedendo permissão 777 para a geração de boleto PDF"
        sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'chmod -R 777 /var/www/web_hostFinanceiro/vendor/dompdf/'
        checagem
	echo -e "Copiando LOGS"
        sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'cp -r /var/www/web_hostFinanceiro_bkp/logs/ /var/www/web_hostFinanceiro/'
        checagem
	 echo -e "Concedendo permissão 777 para os logs"
        sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'chmod -R 777 /var/www/web_hostFinanceiro/logs/'
        checagem
fi
if [ $projeto = "web-ecommerce-admin-back-v1" ]
then
	echo -e "Copiando LOGS"
        sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'cp -r /var/www/web-ecommerce-admin-back-v1_bkp/logs/ /var/www/web-ecommerce-admin-back-v1/'
        checagem
	echo -e "Concedendo permissão 777 para os logs"
		sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'chmod -R 777 /var/www/web-ecommerce-admin-back-v1/logs/'
		checagem
	echo -e "Concedendo permissão 777 para a pasta vendor"
        sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'chmod -R 777 /var/www/web-ecommerce-admin-back-v1/vendor/'
        checagem
fi
if [ $projeto = "web-ecommercebackend-api-v1" ]
then
	echo -e "Copiando LOGS"
        sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'cp -r /var/www/web-ecommercebackend-api-v1_bkp/logs/ /var/www/web-ecommercebackend-api-v1/'
        checagem
	echo -e "Concedendo permissão 777 para os logs"
		sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'chmod -R 777 /var/www/web-ecommercebackend-api-v1/logs/'
		checagem

	echo -e "Concedendo permissão 777 para a geração de boleto PDF"
        sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'chmod -R 777 /var/www/web-ecommercebackend-api-v1/vendor/dompdf/'
        checagem
fi
}

function ecadmup ()
{
echo -e "\n \nMovendo projeto admin...."
sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
rm -r $caminhoremotobkp
mv $caminhoremoto $caminhoremotobkp
mkdir $caminhoremoto
EOF
checagem
echo -e "\n \nCopiando $projeto..."
sshpass -p $PASS scp -r $caminho/dist $USUARIO@$IP:$caminhoremoto/	
checagem
copiaht
}

function copiaenv ()
{
echo -e "\n"
read -p "Deseja copiar o .env da versão do $projeto anterior para o atual?[sim/nao]: " envsim
case $envsim in
"sim")
	envorigin
	;;
"SIM")
	envorigin
         ;;
"Sim")
	envorigin
         ;;
"S")
	envorigin
         ;;
"Yes")
	envorigin
         ;;
"Y")
	envorigin
         ;;
"")
        envorigin
         ;;
*)
	echo -e "\nOK.."
	;;
esac
}

function envorigin ()
{
	sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP <<-EOF >/dev/null
	cp $caminhoremotobkp/.env $caminhoremoto/
	EOF
	checagem
}

function copiaht ()
{
echo -e "\n"
read -p "Deseja copiar o .htaccess da versão do $projeto anterior para o atual?[sim/nao]: " htsim
case $htsim in
"sim")
        htorigin
        ;;
"SIM")
        htorigin
         ;;
"Sim")
        htorigin
         ;;
"S")
        htorigin
         ;;
"Yes")
        htorigin
         ;;
"Y")
        htorigin
         ;;
"")
        htorigin
         ;;
*)
        echo -e "\nOK.."
        ;;
esac
}

function htorigin ()
{
	if [ $projeto = "ecommerce_adm" ]
	then
		hta="dist/.htaccess"
	elif [ $projeto = "web_hostFinanceiro" ]
	then
		hta="Public/.htaccess"
	elif [ $projeto = "bordero" ]
	then
		hta=".htaccess"
	elif [ $projeto = "web-contasapagar-front-v1" ]
	then
		hta="dist/.htaccess"
	else
        hta="public/.htaccess"
    fi
	ht
}

function ht ()
{
sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP <<-EOF >/dev/null
cp $caminhoremotobkp/$hta $caminhoremoto/$hta
EOF
checagem
}

function retorno ()
{
echo -e "\n"
read -p "Deseja atualizar esse projeto $projeto em outro servidor?[sim/nao] " passe
case $passe in
"sim")
        echo -e "\nBuscando Servidores..."
		sleep 2
        server
		sleep 2 & Anime1
		registro
        ;;
"SIM")
        echo -e "\nBuscando Servidores..."
		sleep 2
        server
		sleep 2 & Anime1
		registro
         ;;
"Sim")
        echo -e "\nBuscando Servidores..."
		sleep 2
        server
		sleep 2 & Anime1
		registro
         ;;
"S")
        echo -e "\nBuscando Servidores..."
		sleep 2
        server
		sleep 2 & Anime1
		registro
         ;;
"Yes")
        echo -e "\nBuscando Servidores..."
		sleep 2
        server
		sleep 2 & Anime1
		registro
         ;;
"Y")
        echo -e "\nBuscando Servidores..."
		sleep 2
        server
		sleep 2 & Anime1
		registro
         ;;
"")
        echo -e "\nBuscando Servidores..."
		sleep 2
        server
		sleep 2 & Anime1
		registro
         ;;
*)
        menu
        ;;
esac
}

function retornaversao ()
{

echo -e "\n-----------------------------------------------------------------"
echo "" > ../log.out
logout1="../log.out"
caminho=$(pwd)
USUARIO=""
OP=""
PASS=""
Anime3
echo -e "\n1 -> 192.168.2.15 - WONG(PROXY) \n2 -> 192.168.2.22 - FITZ(NODE1) \n3 -> 192.168.2.23 - SIMMONS(NODE2) \n4 -> 192.168.2.18 - SHU(WEBSERVER-1) \n5 -> 192.168.2.188 - QUILL(WEBSERVER-2)\n"
read -p "Digite a opção que corresponde ao servidor onde deseja retornar a backup do projeto $projeto: " OP
read -p "Digite o usuario do servidor: " USUARIO
read -s -p "Digite a senha: " PASS
echo -e "\n"

if [ -z "$PASS" ] 
then 
PASS="1"
fi

if [ -z "$USUARIO" ] 
then 
USUARIO="root"
fi

case $OP in
"1")
	IP="192.168.2.15"
	sev="WONG(PROXY)"
	checagem
	echo -e "\nATUALMENTE ESSE SERVIDOR NÃO POSSUI PROJETOS, APENAS REALIZA O ENCAMINHAMENTO DE REQUISIÇÕES DE PROXY REVERSO. \nSelecione outro server... \n"
	retornaversao
	;;
"2")
	echo "__________________________________________________________________________"
	IP="192.168.2.22"
    sev="FITZ(SERVERNODE-1)"
	caminhoremoto="/var/www/$projeto"
    caminhoremotobkp="/var/www/"$projeto"_bkp"
	caminhoremotobkp2="/var/www/"$projeto"_bkp2"
	if [ $projeto = "web-empresa-bikes-front-v1" ]
	then
		sleep 2 & echo -e "\nVerificando acesso.."
		> "$logout1"
		sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP 'echo "Acesso OK"' 2>../log.out
		acess=$( cat ../log.out)
		at=$?
		checagem
		echo $acess
		if grep -q "denied" "$logout1" || grep -q "refused" "$logout1" 
		then
			echo "Senha incorreta"
			senha_rollback
		else
			echo "Senha correta"
			echo -e "\nRestaurando backup do projeto $projeto..."
			sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
			mv $caminhoremoto $caminhoremotobkp2
			mv $caminhoremotobkp $caminhoremoto
			mv $caminhoremotobkp2 $caminhoremotobkp
			EOF
			checagem
			sleep 2
			echo "Instalando Atualizações"
			sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
			pm2 stop web-empresa-bikes-front-v1
			cd $caminhoremoto
			pnpm i --production
			pm2 start web-empresa-bikes-front-v1
			pm2 save
			EOF
			checagem
			registro_server_rollback
		fi
	else
		echo -e "\nO backup desse projeto não pode ser retornado nesse servidor. Por favor escolha outro server."
		retornaversao
	fi
	;;
"3")
	echo "__________________________________________________________________________"
	IP="192.168.2.23"
    sev="SIMMONS(SERVERNODE-2)"
	caminhoremoto="/var/www/$projeto"
    caminhoremotobkp="/var/www/"$projeto"_bkp"
	caminhoremotobkp2="/var/www/"$projeto"_bkp2"
	if [ $projeto = "web-empresa-bikes-front-v1" ]
	then
		sleep 2 & echo -e "\nVerificando acesso.."
		> "$logout1"
		sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP 'echo "Acesso OK"' 2>../log.out
		acess=$( cat ../log.out)
		at=$?
		checagem
		echo $acess
		if grep -q "denied" "$logout1" || grep -q "refused" "$logout1" 
		then
			echo "Senha incorreta"
			senha_rollback
		else
			echo "Senha correta"
			echo -e "\nRestaurando backup do projeto $projeto..."
			sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
			mv $caminhoremoto $caminhoremotobkp2
			mv $caminhoremotobkp $caminhoremoto
			mv $caminhoremotobkp2 $caminhoremotobkp
			EOF
			checagem
			sleep 2
			echo "Instalando Atualizações"
			sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
			pm2 stop web-empresa-bikes-front-v1
			cd $caminhoremoto
			pnpm i --production
			pm2 start web-empresa-bikes-front-v1
			pm2 save
			EOF
			checagem
			registro_server_rollback
		fi
	else 
		echo -e "\nO backup desse projeto não pode ser retornado nesse servidor. Por favor escolha outro server."
		retornaversao
	fi
	;;
"4")
	echo "__________________________________________________________________________"
        IP="192.168.2.18"
        sev="SHU(WEBSERVER-1)"
		caminhoremoto="/var/www/$projeto"
        caminhoremotobkp="/var/www/"$projeto"_bkp"
		caminhoremotobkp2="/var/www/"$projeto"_bkp2"
		if [ $projeto != "web-empresa-bikes-front-v1" ]
		then		
			sleep 2 & echo -e "\nVerificando acesso.."
			> "$logout1"
			sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP 'echo "Acesso OK"' 2>../log.out
			acess=$( cat ../log.out)
			at=$?
			checagem
			echo $acess
			if grep -q "denied" "$logout1" || grep -q "refused" "$logout1" 
			then
				echo "Senha incorreta"
				senha_rollback
			else
				echo "Senha correta"
				echo -e "\nRestaurando backup do projeto $projeto..."
				sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
				mv $caminhoremoto $caminhoremotobkp2
				mv $caminhoremotobkp $caminhoremoto
				mv $caminhoremotobkp2 $caminhoremotobkp
				EOF
				checagem
				sleep 2
				echo -e "\nReiniciando Apache2"
				sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl restart apache2'
				checagem
				echo -e "\nVerificando Status Apache2 \n"
				sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl status apache2'
				checagem
				registro_server_rollback
			fi
		else
			echo -e "\nEsse projeto não pode ser atualizado nesse servidor. Por favor escolha outro server."
			retornaversao
		fi
	;;
"5")
	echo "__________________________________________________________________________"
        IP="192.168.2.188"
        sev="QUILL(WEBSERVER-2)"
		caminhoremoto="/var/www/$projeto"
        caminhoremotobkp="/var/www/"$projeto"_bkp"
		caminhoremotobkp2="/var/www/"$projeto"_bkp2"
		if [ $projeto != "web-empresa-bikes-front-v1" ]
		then		
			sleep 2 & echo -e "\nVerificando acesso.."
			> "$logout1"
			sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP 'echo "Acesso OK"' 2>../log.out
			acess=$( cat ../log.out)
			at=$?
			checagem
			echo $acess
			if grep -q "denied" "$logout1" || grep -q "refused" "$logout1" 
			then
				echo "Senha incorreta"
				senha_rollback
			else
				echo "Senha correta"
				echo -e "\nRestaurando backup do projeto $projeto..."
				sshpass -p $PASS ssh -T -o StrictHostKeyChecking=no $USUARIO@$IP  <<-EOF >/dev/null
				mv $caminhoremoto $caminhoremotobkp2
				mv $caminhoremotobkp $caminhoremoto
				mv $caminhoremotobkp2 $caminhoremotobkp
				EOF
				checagem
				sleep 2
				echo -e "\nReiniciando Apache2"
				sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl restart apache2'
				checagem
				echo -e "\nVerificando Status Apache2 \n"
				sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USUARIO@$IP 'systemctl status apache2'
				checagem
				registro_server_rollback
			fi
		else
			echo -e "\nEsse projeto não pode ser atualizado nesse servidor. Por favor escolha outro server."
			retornaversao
		fi
	;;
*)
	echo -e "Opção invalida...🤔 \nTente novamente!!!"
	retornaversao
	;;
esac
menu
}

function senha_rollback ()
{
checagem
pswd=$(echo $PASS | tr 'AsF!@s*' '*')
echo -e "\nSenha incorreta!! \nTente Novamente \noperação: $OP, IP: $IP,USUARIO: $USUARIO, PASS: $pswd [$at]"
echo "" > ../log.out
retornaversao
}

###########################################################################################
##EXECUÇÃO
iniciar
clear
pacotes
inicio
if [ $sair = 0 ]
then
retorno
else
echo "" > ../log.out
exit
fi


############################################################################################
