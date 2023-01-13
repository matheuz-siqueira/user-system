#!/usr/bin/env bash 

#Variáveis 

ARQUIVO_BANCO_DE_DADOS="banco_de_dados.txt"
VERDE="\033[32m" 
VERMELHO="\033[31m" 
SEP=:
TEMP=temp.$$


#Testes 

[ ! -e "$ARQUIVO_BANCO_DE_DADOS" ] && echo "Erro. Arquivo de banco de dados não existe." && exit 1 
[ ! -w "$ARQUIVO_BANCO_DE_DADOS" ] && echo "Erro. Permissão de escrita negada." && exit 1 
[ ! -r "$ARQUIVO_BANCO_DE_DADOS" ] && echo "Erro. Permissão de leitura negada." && exit 1
[ ! -x "$(which dialog)" ] && sudo apt install dialog -y > /dev/null 2>&1 

#Funções 


ListaUsuarios()
{
	egrep -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS" | tr : ' ' > "$TEMP"
        dialog --title "Lista de Usuários" --textbox "$TEMP" 20 40 
	rm -rf "$TEMP"	
}

ValidaExistenciaUsuario()
{
	grep -qi "$1$SEP" "$ARQUIVO_BANCO_DE_DADOS"
}

OrdenaLista ()
{
	sort "$ARQUIVO_BANCO_DE_DADOS" > "$TEMP" 
	mv "$TEMP" "$ARQUIVO_BANCO_DE_DADOS"  
}

# Execução 

while : 
do 
	acao=$(dialog --title "Gerenciamento de usuários 2.0" \
	      --stdout --menu "Escolha uma das opções abaixo:" \
              0 0 0 \
              listar "Listar todos os usuários do sistema" \
              remover "Remover um usuário do sistema" \
              inserir "Inserir um novo usuário no sistema") 
	[ $? -ne 0 ] && break && exit 0
 	case $acao in 
		listar) ListaUsuarios  ;; 
		inserir) 
			ultimo_id="$(egrep -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS" | sort | tail -n 1 | cut -d $SEP -f 1)"   
			prox_id=$(($ultimo_id+1))

			nome=$(dialog --title "Cadastro de Usuários" --stdout --inputbox "Digite o nome" 0 0)
			if test ! "$nome"; then 
				dialog --title "Erro!" --msgbox "Precisa informar o nome do usuário" 0 0 
				continue 
			fi 

			ValidaExistenciaUsuario "$nome" && {
			dialog --title "Erro!" --msgbox "Usuário já cadastrado no sistema!" 6 40 
			exit 1 	
			}
			email=$(dialog --title "Cadastro de Usuários" --stdout --inputbox "Digite o E-mail" 0 0) 
			[ $? -ne 0 ] && continue   
			echo "$prox_id$SEP$nome$SEP$email" >> "$ARQUIVO_BANCO_DE_DADOS" 
			dialog --title "Sucesso!" --msgbox "Usuário cadastrado com sucesso!" 6 40
			ListaUsuarios 
		;;
		remover) RemoveUsuario 
			usuarios=$(egrep -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS" | sort -h | cut -d $SEP -f 1,2 | sed 's/:/ "/;s/$/"/') 
			id_usuario=$(eval dialog --stdout --menu \"Escolha um usuário:\" 0 0 0 $usuarios)

			[ $? -ne 0 ] && continue 

			grep -i -v "^$id_usuario$SEP" "$ARQUIVO_BANCO_DE_DADOS" > "$TEMP" 
			mv "$TEMP" "$ARQUIVO_BANCO_DE_DADOS" 
			
			dialog --title "Sucesso!" --msgbox "Usuário removido com sucesso!" 
			ListaUsuario
		;;
	esac
done 
