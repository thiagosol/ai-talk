#!/bin/bash

cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 8000;

    # --- ROTA DE HEALTH CHECK (Sem senha, para o Kubernetes) ---
    location /health {
        default_type application/json;
        return 200 '{"status": "online"}';
    }

    # --- ROTA DA IA (Protegida) ---
    location / {
        default_type application/json;
        set \$auth_valid 0;
        
        if (\$http_authorization = "Bearer ${API_SECRET_KEY}") {
            set \$auth_valid 1;
        }

        if (\$auth_valid = 0) {
            return 401 '{"error": "Acesso negado. Token invalido."}';
        }

        proxy_pass http://127.0.0.1:11434;
        proxy_buffering off;
    }
}
EOF

ollama serve &
sleep 5

echo "Garantindo que o modelo qwen2.5:3b está presente..."
ollama pull qwen2.5:3b

echo "✅ Servidor IA Seguro rodando na porta 8000!"
nginx -g "daemon off;"