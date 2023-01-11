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

#Funções 

MostraUsuarioNaTela()
{
	local id="$(echo $1 | cut -d $SEP -f 1)" 
        local nome="$(echo $1 | cut -d $SEP -f 2)"
	local email="$(echo $1 | cut -d $SEP -f 3)"   
                                                  
        echo -e "${VERDE}ID: ${VERMELHO}$id"
        echo -e "${VERDE}Nome: ${VERMELHO}$nome"
        echo -e "${VERDE}E-mail: ${VERMELHO}$email" 	
}


ListaUsuarios()
{
	while read -r line 
	do 
		[ "$(echo $line | cut -c1)" = "#" ] && continue 
		[ ! "$line" ] && continue
		MostraUsuarioNaTela "$line"		
	done < "$ARQUIVO_BANCO_DE_DADOS"
	OrdenaLista
}

ValidaExistenciaUsuario()
{
	grep -qi "$1$SEP" "$ARQUIVO_BANCO_DE_DADOS"
}

InsereUsuario()
{
	local nome=$(echo "$1" | cut -d $SEP -f 2) 
	if ValidaExistenciaUsuario "$nome" 
	then
		echo "Erro. usuário já existente" 
	else
		echo "$*" >> "$ARQUIVO_BANCO_DE_DADOS" 
		echo "Usuário cadastrado com sucesso!" 
	fi
	OrdenaLista
}

ApagaUsuario()
{
	ValidaExistenciaUsuario "$1" || return 

	grep -iv "$1$SEP" "$ARQUIVO_BANCO_DE_DADOS" > "$TEMP" 
	mv "$TEMP" "$ARQUIVO_BANCO_DE_DADOS"
	echo "Usuário removido com sucesso!"
	OrdenaLista
}

OrdenaLista ()
{
	sort "$ARQUIVO_BANCO_DE_DADOS" > "$TEMP" 
	mv "$TEMP" "$ARQUIVO_BANCO_DE_DADOS"  
}
