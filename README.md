# atualizacao_de_projeto_js
Este script, realiza a copia dos arquivos necessários para atualização de um projeto node. O detalhe aqui é que não precisamos inserir a senha a cada solicitação de copia (scp), A senha é solicitada uma unica vez e é repassado como parâmetro para o pacote sshpass.

O processo normalmente seria, "scp -r usuario@ip:/caminho/do/repositorio/remoto", na sequencia solicita a senha do usuario.

O problema é que, para cada arquivo/repositorio é necessario o preenchimento dessas informações, bem como o preenchimento da senha do usuario a cada solicitação. O que torna o processo longo e enfadante.

Esse roteiro foi feito para automatizar essa rotina, pois os arquivos copiados no repositorio remoto são sempre os mesmos. Sendo assim só é necessario informar uma unica vez no inicio do script.

Outro ponto é que, devido a complexidade do ambiente com mais de um servidor de Testes e Produção, fez-se necessario adaptar a atualização em mais servidores para validação do resultado antes e no moemnto da implantação.

Como esse script atualiza um repositorio no servidor web do projeto node, na sequencia o script atualiza as dependencias do projeto para execução em produção e inicia o server js

# REQUISITOS


### SSHPASS

`apt-get update`

`apt-get install sshpass`


### PNPM
`wget -qO- https://get.pnpm.io/install.sh | sh -`

`export PNPM_HOME="/root/.local/share/pnpm"`

`export PATH="$PNPM_HOME:$PATH"`

`source /root/.bashrc`


### NODE
`pnpm env use --global lts`

# IMAGENS

![ec991931-fdc4-41b0-bdab-c605a5eb3ca7](https://github.com/user-attachments/assets/1fed7206-10ce-4feb-be04-a003e644d386)

_Inicio do Processo de atualização_




![4ecf4c99-93e2-4bef-8f45-fa2f6268d74e](https://github.com/user-attachments/assets/99c7c331-1554-47d0-aff0-b0fca224dff2)

_Atualização de pacotes necessarios para a execução do stript_




![91c92e0c-167d-4e71-a9a9-9440e87d0ed6](https://github.com/user-attachments/assets/6fd32348-8f67-42dc-8508-75849c308dbb)
_Tela de seleção de Projeto a atualizar_


