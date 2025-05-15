# GestãoFacil

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

Assistente de voz para gestão financeira, criado para registrar vendas à vista, fiado e gastos por comando de voz. Gera relatórios em PDF e CSV, possui dashboard customizável, aba de transações e calculadora integrada.

---

## 📋 Funcionalidades

* Reconhecimento de voz para inserir valores e descrições ("80,00 reais", etc.).
* Registro de transações dos tipos: **À vista**, **Fiado** e **Gastos**.
* Dashboard com tema claro/escuro e filtros.
* Tela de **Relatório de Transações** com resumo, swipe para editar/excluir e filtros.
* Tela de **Relatório** (gráficos de pizza) e exportação direta para PDF/CSV.
* Aba **Relatórios Salvos** para consultar, abrir, compartilhar ou excluir arquivos gerados.
* **Calculadora** básica de 4 operações acessível na Dashboard.

---

## 🚀 Como executar

### Pré-requisitos

* Flutter SDK 3.1.0 ou superior
* Android SDK (API 33+)
* Xcode 11.0+ (para compilar iOS, opcional)

### Passos

1. Clone o repositório:

   ```bash
   git clone https://github.com/professorwell/gestaofacil.git
   cd gestaofacil
   ```
2. Instale as dependências:

   ```bash
   flutter pub get
   ```
3. Execute no emulador ou dispositivo Android:

   ```bash
   flutter run
   ```
4. Compile release APK:

   ```bash
   flutter build apk --release
   ```

---

## 🗂️ Estrutura do Projeto

```
lib/
 ├── db/                 # Helper de SQLite
 ├── models/             # Modelos de dados
 ├── pages/              # Telas (Dashboard, ListPage, ReportPage...)
 ├── services/           # Serviços (voz, banco)
 └── main.dart           # Ponto de entrada
android/
ios/
pubspec.yaml            # Dependências e assets
README.md               # Documentação do projeto
LICENSE                 # Licença MIT
```

---

## 🤝 Contribuindo

1. Fork este repositório
2. Crie uma branch para sua feature: `git checkout -b feature/nome`
3. Commit suas alterações: `git commit -m "feat: descrição da feature"`
4. Push para a branch: `git push origin feature/nome`
5. Abra um Pull Request no GitHub

---

## 📄 Licença

Este projeto está licenciado sob a **MIT License**. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
