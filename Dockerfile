# Usa a imagem oficial do Ollama (Linux base)
FROM ollama/ollama:latest

# Instala o Nginx para servir de Proxy e Proteção
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Copia o nosso script maestro para dentro da imagem
COPY start.sh /start.sh
RUN chmod +x /start.sh

# A porta 11434 ficará bloqueada apenas para uso interno (localhost). 
# Vamos expor a porta 8000, que é a do Nginx (Segura)
EXPOSE 8000

# Executa o script ao ligar o container
CMD ["/start.sh"]