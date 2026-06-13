# D&D 8Bits

RPG isometrico de fantasia para Windows e macOS, desenvolvido em Godot.

O projeto combina um mundo aberto gerado proceduralmente, narrativa emergente,
combate tatico em turnos e regras proximas ao SRD 5.2.1. O universo, as culturas,
as divindades e todo conteudo nao coberto pelo SRD serao originais.

## Estado

O projeto esta na fase de fundacao tecnica e pre-producao. A visao completa esta
registrada em `docs/GAME_DESIGN.md`; a ordem de implementacao esta em
`docs/ROADMAP.md`.

## Abrir o projeto

1. Instale uma versao estavel recente do Godot 4.
2. Importe `project.godot` pelo gerenciador de projetos.
3. Execute a cena principal com `F6` ou o projeto com `F5`.

O primeiro executavel implementa apenas a fundacao: tela inicial, selecao de
idioma e criacao deterministica de uma campanha por `seed`.

## Plataformas

- Windows x86-64
- macOS Universal (Intel e Apple Silicon)
- teclado e mouse
- controles compativeis com o sistema

## Documentacao

- `docs/PROJECT_MEMORY.md`: memoria persistente e regras de colaboracao.
- `docs/GAME_DESIGN.md`: especificacao funcional do jogo.
- `docs/TECHNICAL_SPEC.md`: arquitetura e requisitos tecnicos.
- `docs/ROADMAP.md`: marcos e ordem de entrega.
- `docs/DECISIONS.md`: registro de decisoes arquiteturais e de produto.
- `docs/LEGAL.md`: limites de propriedade intelectual e atribuicao.

## Prototipo anterior

O antigo prototipo web foi preservado em `archive/web-prototype/` apenas como
registro historico. Ele nao representa a tecnologia nem a arquitetura finais.
