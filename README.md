# 🤖 Ai Talk - LLM Local Integrado

O **Ai Talk** é uma API de Inteligência Artificial auto-hospedada, projetada para rodar de forma privada e segura no seu próprio servidor. Ele utiliza o poderoso **Ollama** para executar modelos de linguagem (como Qwen e Llama) localmente, eliminando custos de API externa e garantindo total controle sobre os dados.

## 🚀 Visão Geral

Este projeto funciona como um **Proxy de IA**. Ele expõe uma interface compatível com a OpenAI na porta `8000`, mas na verdade está rodando um LLM diretamente na máquina. Tudo é protegido por uma chave secreta (`API_SECRET_KEY`) configurada via Kubernetes.

## 📋 Requisitos

- **Kubernetes Cluster** (com namespace `deploy-ai` criado)
- **Volumes Persistentes** configurados no cluster
- **Secrets** configurados: `AI_TALK_KEY`
- **Registry Privado**: `registry-ai.tmsol.app`

## 📦 Imagem e Deploy

A imagem Docker já está disponível em nosso registry privado e é utilizada diretamente pelo Deploy-Kit.

- **Imagem**: `registry-ai.tmsol.app/ai-talk:latest`
- **Porta Exposta**: `8000` (HTTP)

## 🛡️ Segurança

O servidor **não é público**. O acesso é estritamente controlado por uma chave secreta:

```bash
# Exemplo de como chamar (Python)
import requests

headers = {
    "Authorization": "Bearer SUA_API_KEY_SECRETA_AQUI"
}

response = requests.post(
    "http://ai-talk-service.deploy-ai.svc.cluster.local:8000/v1/chat/completions", 
    json={...}, 
    headers=headers
)
```

## 💾 Armazenamento de Modelos

Os modelos de IA são grandes (vários GBs). Para evitar que sejam baixados toda vez que o servidor reiniciar, utilizamos um **Volume Persistente** mapeado para `/root/.ollama`. Isso garante que, após o primeiro download, o modelo fique armazenado permanentemente no disco do cluster.