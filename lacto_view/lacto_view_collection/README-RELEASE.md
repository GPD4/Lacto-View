# Guia de Preparação para Google Play Store

## Configuração de Assinatura

### Keystore Gerada
Foi criada uma keystore para assinatura do app:
- Arquivo: `android/lacto-view-release-key.jks`
- Alias: `lacto-view-key`
- Validade: 10.000 dias
- Tipo: RSA 2048 bits

### Arquivo key.properties
Criado em `android/key.properties` com as credenciais:
```properties
storePassword=lactoview2025
keyPassword=lactoview2025
keyAlias=lacto-view-key
storeFile=lacto-view-release-key.jks
```

### Segurança
Os seguintes padrões foram adicionados ao `.gitignore`:
- `*.jks`
- `*.keystore`
- `**/key.properties`

## Configuração do build.gradle.kts

### Arquivo Customizado
Foi criado `android/app/build.gradle.release.kts` com:
- Carregamento do `key.properties`
- Configuração de `signingConfigs` para release
- Application ID: `br.com.gpd4.lactoview`
- Namespace: `br.com.gpd4.lactoview`

### Para Usar a Configuração de Release

#### Opção 1: Substituir temporariamente
```bash
cd android/app
cp build.gradle.kts build.gradle.kts.backup
cp build.gradle.release.kts build.gradle.kts
```

#### Opção 2: Build manual
Use o arquivo `build.gradle.release.kts` como referência para atualizar `build.gradle.kts`

## Gerar Builds de Release

### App Bundle (.aab) para Play Store
```bash
flutter build appbundle --release
```
O arquivo será gerado em:
`build/app/outputs/bundle/release/app-release.aab`

### APK (.apk) para distribuição
```bash
flutter build apk --release
```
O arquivo será gerado em:
`build/app/outputs/flutter-apk/app-release.apk`

### APK Split por ABI
```bash
flutter build apk --split-per-abi --release
```
Gera APKs otimizados para cada arquitetura em:
`build/app/outputs/flutter-apk/`

## Versionamento

Versão atual definida em `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

Formato: `MAJOR.MINOR.PATCH+BUILD_NUMBER`
- versionName: 1.0.0
- versionCode: 1

## Próximos Passos

1. **Backup da Keystore**: Guardar `lacto-view-release-key.jks` em local seguro
2. **Aplicar configuração**: Usar `build.gradle.release.kts` como base
3. **Testar build**: Executar `flutter build appbundle --release`
4. **Validar AAB**: Verificar o arquivo gerado
5. **Play Console**: Fazer upload do AAB para Google Play Console

## Observações Importantes

- A keystore e key.properties NÃO devem ser commitadas no git
- Manter backup seguro da keystore (perder significa não poder atualizar o app)
- Para publicação, considere usar Google Play App Signing
- Revisar permissões no AndroidManifest.xml antes da publicação
