#!/bin/bash

# 1. Cria a configuração do Nginx dinamicamente usando a variável de ambiente do Kubernetes
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 8000;

    location = /health {
        default_type text/plain;
        return 200 'OK';
    }

    location / {
        set \$auth_valid 0;
        
        # Valida o token recebido no header
        if (\$http_authorization = "Bearer ${API_SECRET_KEY}") {
            set \$auth_valid 1;
        }

        # Bloqueia se a senha estiver errada
        if (\$auth_valid = 0) {
            default_type application/json;
            return 401 '{"error": "Acesso negado. Token invalido."}';
        }

        # Repassa a requisição localmente para o Ollama
        proxy_pass http://127.0.0.1:11434;
        proxy_buffering off;
    }
}
EOF

# 2. Inicia o Ollama em background
ollama serve &

# Espera a API do Ollama ligar
sleep 5

# 3. Baixa o modelo. Se o disco estiver mapeado no Kubernetes, 
# ele só valida os arquivos locais e passa direto em 1 segundo!
echo "Garantindo que o modelo qwen2.5:3b está presente..."
ollama pull qwen2.5:3b

echo "✅ Servidor IA Seguro rodando na porta 8000!"

# 4. Inicia o Nginx em foreground (mantém o container vivo)
nginx -g 'daemon off;'
