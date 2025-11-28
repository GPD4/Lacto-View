# Matriz de Permissões e Compliance (MPC)

## Projeto: Lacto-View

### Identificação do App
- **ID do Pacote**: com.example.lacto_view
- **Nome**: Lacto-View
- **Descrição**: Sistema de coleta e gestão de produção leiteira
- **Versão**: 1.0.0+1

---

## Matriz de Permissões

| Feature principal | Dado mínimo | Permissão | Tipo (inst./exec./esp.) | Pedido em contexto (mensagem) | Alternativa digna | Proteção/ret. | Política Play / Declaração |
|-------------------|-------------|-----------|------------------------|-------------------------------|-------------------|---------------|----------------------------|
| Autenticação de usuários | E-mail, credenciais | INTERNET | normal (instalação) | Concedida automaticamente pelo sistema | Impossível usar o app sem conexão; modo offline limitado futuro | Dados transmitidos via HTTPS/TLS, armazenados no Firebase Auth com criptografia | Firebase Authentication - Dados de autenticação gerenciados pelo Google |
| Sincronização de dados (Firestore) | Dados de coleta de leite, produtores, propriedades | INTERNET | normal (instalação) | Concedida automaticamente pelo sistema | Cache local temporário; sincronização quando conectar | Dados criptografados em trânsito (TLS), armazenamento Firestore com regras de segurança | Cloud Firestore - Dados sensíveis de negócio protegidos por regras |
| Persistência local de preferências | Configurações, sessão de usuário | N/A (SharedPreferences) | Armazenamento interno do app | N/A - armazenamento privado do app | Não aplicável; necessário para funcionamento | Dados no sandbox do app, não acessíveis por terceiros | Política de Privacidade - coleta de dados mínimos |
| Consulta de processos de texto | Compartilhamento de texto entre apps | QUERY_ALL_PACKAGES (implícito) | normal (instalação) | Filtro de intent no manifest para ACTION_PROCESS_TEXT | Funcionalidade opcional; app funciona sem | N/A - apenas metadados de intent | Declaração de Uso de Dados - apenas para funcionalidade específica do Flutter |

---

## Análise de Funcionalidades

### 1. Autenticação (Firebase Auth)
- **Meta do usuário**: Fazer login no sistema para registrar coletas de leite
- **Dado mínimo necessário**: E-mail e senha ou token de autenticação
- **Permissões**: INTERNET (normal)
- **Justificativa**: Firebase Authentication requer conexão de rede
- **Alternativa**: Modo offline futuro com autenticação cacheada
- **Proteção**: Credenciais nunca armazenadas localmente; tokens gerenciados pelo Firebase SDK

### 2. Gestão de Coletas de Leite
- **Meta do usuário**: Registrar dados de coleta (volume, temperatura, pH, produtor)
- **Dado mínimo necessário**: Informações de coleta (não-sensíveis do ponto de vista de privacidade Android)
- **Permissões**: INTERNET (para sincronização)
- **Justificativa**: Envio de dados para backend via Firestore
- **Alternativa**: Armazenamento local com sincronização posterior
- **Proteção**: Dados criptografados em trânsito; regras de segurança Firestore

### 3. Busca e Listagem de Produtores
- **Meta do usuário**: Encontrar produtor para associar à coleta
- **Dado mínimo necessário**: Nome, ID e propriedade do produtor
- **Permissões**: INTERNET
- **Justificativa**: Consulta ao Firestore
- **Alternativa**: Cache local de produtores recentes
- **Proteção**: Acesso controlado por regras de autenticação Firestore

### 4. Visualização de Perfil
- **Meta do usuário**: Ver e editar informações de perfil do coletor
- **Dado mínimo necessário**: Nome, e-mail, role (produtor/coletor/admin)
- **Permissões**: INTERNET
- **Justificativa**: Leitura/escrita no Firestore
- **Alternativa**: Visualização de dados cacheados
- **Proteção**: Dados de perfil protegidos por autenticação

---

## Permissões Não Solicitadas

### Permissões deliberadamente NÃO incluídas:
- **CAMERA**: O app não utiliza câmera para captura de fotos
- **ACCESS_FINE_LOCATION / ACCESS_COARSE_LOCATION**: Não há rastreamento de localização
- **READ_EXTERNAL_STORAGE / WRITE_EXTERNAL_STORAGE**: Não há acesso a arquivos externos
- **READ_CONTACTS**: Não há acesso à agenda de contatos
- **RECORD_AUDIO**: Não há gravação de áudio
- **CALL_PHONE**: Não há realização de chamadas
- **SEND_SMS**: Não há envio de SMS
- **READ_PHONE_STATE**: Não há leitura de estado do telefone
- **ACCESS_BACKGROUND_LOCATION**: Não há rastreamento em background

---

## Conformidade com Google Play

### 1. Data Safety Section (Seção de Segurança de Dados)
**Dados coletados:**
- E-mail (para autenticação)
- Nome completo (perfil do usuário)
- Dados de coleta de leite (volume, temperatura, pH - dados de negócio)
- Informações de produtor e propriedade

**Propósito:**
- Funcionalidade do app (autenticação e registro de coletas)
- Não há uso para publicidade
- Não há compartilhamento com terceiros além do Firebase/Google

**Segurança:**
- Dados criptografados em trânsito (TLS/SSL)
- Dados em repouso protegidos pelo Firebase
- Autenticação obrigatória para acesso

### 2. Política de Privacidade
- URL deve ser fornecida na Play Console
- Deve descrever coleta, uso e proteção de dados
- Deve mencionar uso do Firebase e Google Services

### 3. Declarações Necessárias
- **Firebase**: Declarar uso de Firebase Authentication e Firestore
- **Google Play Services**: SDK integrado para Firebase
- **Ausência de permissões dangerous**: Facilita aprovação

---

## Ciclo de Vida dos Dados

### Retenção
- **Dados de autenticação**: Mantidos enquanto conta estiver ativa
- **Dados de coleta**: Mantidos indefinidamente para histórico (regulamentação laticínios)
- **Cache local**: Limpo ao fazer logout ou desinstalar app

### Descarte
- **Logout**: Remove tokens de autenticação local
- **Desinstalação**: Remove todos os dados do sandbox do app
- **Exclusão de conta**: Deve acionar remoção no Firebase (função a implementar)

---

## UX de Consentimento

### Tela de Login
- Informar que ao fazer login, o usuário autoriza coleta de e-mail e nome
- Link para Política de Privacidade visível

### Primeira Execução
- Tela de boas-vindas explicando funcionalidades
- Destacar que app requer conexão à internet para funcionar

### Configurações
- Opção de "Limpar cache local"
- Opção de "Sair" (logout) com confirmação
- Link para Política de Privacidade

---

## Diagrama de Fluxo de Consentimento

```
Abertura do App
    │
    ├──> Não autenticado
    │       │
    │       └──> Tela de Login
    │               │
    │               ├──> Aceita (implícito ao fazer login)
    │               │       └──> Acesso completo ao app
    │               │
    │               └──> Rejeita (não faz login)
    │                       └──> Não pode usar o app
    │
    └──> Autenticado
            │
            └──> Acesso completo
                    │
                    ├──> Conexão disponível
                    │       └──> Funcionalidade completa
                    │
                    └──> Sem conexão
                            └──> Mensagem: "Conecte-se para sincronizar"
```

---

## Checklist de Conformidade

- [x] Permissões declaradas no AndroidManifest.xml estão justificadas
- [x] Não há permissões "dangerous" que exijam runtime request
- [x] App funciona com permissões mínimas (apenas INTERNET implícito)
- [x] Política de Privacidade será criada antes da publicação
- [x] Data Safety Section será preenchida corretamente na Play Console
- [x] Uso do Firebase está documentado
- [x] Não há coleta de dados sensíveis do dispositivo
- [x] Não há rastreamento de localização
- [x] Não há acesso a câmera, microfone ou arquivos
- [x] App respeita sandbox do Android
- [x] Comunicação usa HTTPS (Firebase)

---

## Notas Adicionais

### Por que não há permissões dangerous?
O Lacto-View é um app de gestão de dados de negócio (coleta de leite) que:
- Não precisa de localização (dados inseridos manualmente)
- Não precisa de câmera (dados numéricos e texto)
- Não precisa de armazenamento externo (usa Firestore)
- Não precisa de contatos, chamadas ou SMS

### Boas Práticas Implementadas
1. **Princípio do privilégio mínimo**: Apenas INTERNET (automática)
2. **Transparência**: Dados coletados são claros e justificados
3. **Segurança**: Firebase fornece criptografia e autenticação
4. **Escolha do usuário**: Usuário pode não fazer login (mas app não funciona)
5. **Dados locais protegidos**: Sandbox do Android

### Próximos Passos para Publicação
1. Criar Política de Privacidade formal (URL externa)
2. Preencher Data Safety Section na Play Console
3. Adicionar termos de uso se aplicável
4. Revisar google-services.json (não commitar com credenciais de produção)
5. Considerar implementar exclusão de conta (GDPR/LGPD)

---

**Documento criado em**: 28 de novembro de 2025  
**Versão**: 1.0  
**Responsável**: Equipe Lacto-View
