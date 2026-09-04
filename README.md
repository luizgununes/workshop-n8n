# Workshop: n8n + EvolutionAPI

Ambiente pronto para o workshop de automação: um bot de WhatsApp que responde cotações de moedas sob demanda.

## Conteúdo

| Serviço      | Versão | Porta | Papel                          |
| ------------ | ------ | ----- | ------------------------------ |
| n8n          | 2.37.7 | 5678  | Editor e Execução dos Fluxos   |
| EvolutionAPI | v2.3.7 | 8080  | API não-oficial do WhatsApp    |
| PostgreSQL   | 15     | 5432  | Banco do n8n e da EvolutionAPI |
| Redis        | 7      | —     | Cache da EvolutionAPI          |

## Configuração Inicial

1. Clique no botão "Code" na página do GitHub do repositório;
2. Em seguida, clique no botão "Create codespace on main";
3. Assim que a máquina terminar de carregar, abra o terminal;
4. Insira o comando `./setup.sh` e aperte Enter;
5. Deixe a porta **8080** pública na aba Ports;
6. Abra o Manager da EvolutionAPI e insira a API key `workshop-evolution-key`;
7. Crie uma instância chamada `workshop` e pareie o celular pelo QR Code;
8. Abra o n8n, crie uma conta e instale o community node `n8n-nodes-evolution-api`.

Os endereços do n8n e do Manager saem da aba **Ports** do Codespaces. Eles seguem sempre o mesmo formato, mudando só o número da porta:

- n8n: `https://<nome-do-codespace>-5678.app.github.dev`
- EvolutionAPI Manager: `https://<nome-do-codespace>-8080.app.github.dev/manager`

O `<nome-do-codespace>` é aquele nome gerado aleatoriamente que aparece na aba Ports, tipo `glorious-tribble-97v76r9jw5p2747w`.

Documentação da API de cotações: https://docs.awesomeapi.com.br/api-de-moedas

### Nó Code

```js
const body = $json.body;
const dados = body.data;

const texto =
  dados.message?.conversation ?? dados.message?.extendedTextMessage?.text ?? "";
const telefone = dados.key.remoteJid.split("@")[0];

const digitos = (jid) => (jid ?? "").split("@")[0].replace(/\D/g, "");
const minhaConversa =
  digitos(body.sender).slice(-8) === digitos(dados.key.remoteJid).slice(-8);

if (!minhaConversa || texto.startsWith("🤖")) {
  return [];
}

const limpo = texto
  .toLowerCase()
  .normalize("NFD")
  .replace(/[\u0300-\u036f]/g, "")
  .trim();

const moedas = {
  dolar: "USD",
  usd: "USD",
  euro: "EUR",
  eur: "EUR",
  bitcoin: "BTC",
  btc: "BTC",
};

let intencao = "desconhecido";
let moeda = "";

const achou = Object.keys(moedas).find((m) => limpo.includes(m));

if (achou) {
  intencao = "cotacao";
  moeda = moedas[achou];
} else if (/\b(ajuda|menu|oi|ola|comandos)\b/.test(limpo)) {
  intencao = "ajuda";
}

return [{ json: { intencao, moeda, texto, telefone, nome: dados.pushName } }];
```

### URL da Requisição de Cotação

```
https://economia.awesomeapi.com.br/json/last/{{ $json.moeda }}-BRL?token=sk_35zpO7Wxcsl60ybKlbMaXkmLWqlTfF_ZFSjwJgV308uGuiu9F35P8KLTQH8W2
```

### Mensagem da Cotação

```
🤖 O {{ Object.values($json)[0].name.split('/')[0].split(' ')[0] }} hoje está R$ {{ Object.values($json)[0].bid.toNumber().toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }}
```

### Mensagem de Ajuda

```
🤖 Oi! Eu sou o bot de cotações do workshop.

Me manda o nome de uma moeda que eu te digo quanto ela está valendo:

• dólar, dolar ou usd
• euro ou eur
• bitcoin ou btc

Pode escrever numa frase também, tipo "quanto tá o dólar hoje?"
```

### Mensagem de Fallback

```
🤖 Não entendi. Tenta assim:

• dólar, dolar ou usd
• euro ou eur
• bitcoin ou btc
```

As quatro respostas começam com 🤖 de propósito: é a assinatura que o nó Code procura para descartar o eco das próprias mensagens do BOT.

### Credencial da EvolutionAPI no n8n

- URL: `http://evolution-api:8080`
- API Key: `workshop-evolution-key`
