#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <arquivo_de_configuracao>"
    exit 1
fi

arquivo_configuracao="$1"
if [ ! -f "$arquivo_configuracao" ]; then
    echo "Arquivo de configuração '$arquivo_configuracao' não encontrado!"
    exit 1
fi

arquivos_log=()
while read -r linha; do
    [[ "$linha" =~ ^#.*$ || -z "$linha" ]] && continue
    arquivos_log+=("$linha")
done < "$arquivo_configuracao"

if [ "${#arquivos_log[@]}" -eq 0 ]; then
    echo "Nenhum arquivo de log especificado no arquivo de configuração!"
    exit 1
fi

tmux new-session -d -s monitoramento_logs

for i in "${!arquivos_log[@]}"; do
    arquivo="${arquivos_log[$i]}"
    
    if [ "$i" -eq 0 ]; then
        tmux send-keys "tail -f $arquivo" C-m
    else
        tmux split-window -v
        tmux send-keys "tail -f $arquivo" C-m
    fi
    
    tmux select-layout tiled
done

tmux attach-session -t monitoramento_logs
