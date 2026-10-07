# MealFinder

Primeira etapa de um catálogo acadêmico de receitas em Flutter. O foco desta versão é demonstrar uma integração real e organizada com uma API externa.

## API utilizada

- **TheMealDB API V1** — https://www.themealdb.com/api.php
- Endpoint desta etapa: `https://www.themealdb.com/api/json/v1/1/search.php?s=chicken`
- Chave de teste gratuita: `1`

O `MealService` faz uma requisição HTTP GET para esse endpoint. A resposta JSON é convertida em objetos `Meal`, que a `HomePage` entrega ao widget `MealCard`.

## Tecnologias

- Flutter e Dart
- pacote [`http`](https://pub.dev/packages/http)
- TheMealDB API

## Estrutura principal

```text
lib/
├── main.dart                  # inicia o app, tema e HomePage
├── models/meal.dart           # modelo dos dados da receita
├── services/meal_service.dart # comunicação com a API
├── screens/home_page.dart     # única tela funcional desta etapa
├── theme/app_theme.dart       # cores e estilos centralizados
└── widgets/meal_card.dart     # card reutilizável de receita
```

## Como executar

1. Na pasta do projeto, execute `flutter pub get` para instalar as dependências.
2. Conecte um dispositivo, abra um emulador ou escolha Chrome/Windows como destino.
3. Execute `flutter run`.
4. Na tela inicial, as receitas de frango devem aparecer após o indicador de carregamento. Puxe a lista para baixo para consultar a API novamente.

Para conferir a resposta da API diretamente, abra o endpoint listado acima no navegador. Se não houver conexão, a tela mostra uma mensagem de erro e o botão para tentar de novo.

## Funcionalidades atuais

- Consulta real à TheMealDB
- Model `Meal` com id, nome, imagem, categoria e origem
- Tela inicial com cards de receitas
- Estados de carregamento, vazio e erro
- Campo de pesquisa visual, reservado para a próxima etapa

## Roadmap

### Etapa 1 — atual

- [x] Estrutura do projeto
- [x] Integração com TheMealDB
- [x] Model Meal
- [x] MealService
- [x] HomePage
- [x] Cards
- [x] Loading
- [x] Tratamento de erro

### Próximas etapas

- [ ] Pesquisa por nome
- [ ] Tela de detalhes
- [ ] Categorias
- [ ] Filtros
- [ ] Receita aleatória
- [ ] Favoritos
- [ ] Melhorias de UX/UI
