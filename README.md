# Compromissos — Agenda de Campo

Exercício da Aula 7 — Consulta aos compromissos do calendário
Programação para Dispositivos Móveis I · Prof. Arley · Fatec Jacareí — DSM

**Integrante:** Rafael Medeiros — RA 2581392513017

Aplicativo Flutter para Android que consulta o calendário do dispositivo e lista
os compromissos de hoje e dos próximos seis dias.

- Pede a permissão de acesso ao calendário ao tocar em **Consultar compromissos**.
- Lê todos os calendários do aparelho com o pacote `device_calendar`.
- Mostra os compromissos em ordem cronológica, separados por dia, com título,
  calendário, início, fim, local e descrição (toque no cartão para ver tudo).
- Marca os eventos de dia inteiro.
- Mostra um indicador de carregamento e avisa quando não há compromissos, quando
  o acesso é negado ou quando a consulta falha.

## Permissões no Android

Em `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```

O app só lê, mas o `device_calendar` pede leitura e escrita juntas no Android.
Sem as duas declaradas, a permissão nunca é concedida.

Para o build de release, `android/app/proguard-rules.pro` mantém as classes do
plugin (`-keep class com.builttoroam.devicecalendar.** { *; }`), como pede a
documentação do pacote.

## Rodar

```bash
flutter pub get
flutter run            # com um celular Android conectado
flutter build apk      # gera build/app/outputs/flutter-apk/app-release.apk
```

Plataforma escolhida: **Android**. Todo o código está em `lib/main.dart`.

Visual: paleta e fontes (Fraunces, Newsreader, IBM Plex Mono) do meu portfólio,
o "Caderno de Campo".
