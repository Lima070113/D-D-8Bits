# D&D 8Bits

RPG isometrico de fantasia para Windows e macOS, desenvolvido em Godot.

O projeto combina um mundo aberto gerado proceduralmente, narrativa emergente,
combate tatico em turnos e regras proximas ao SRD 5.2.1. O universo, as culturas,
as divindades e todo conteudo nao coberto pelo SRD serao originais.

## Estado

O projeto esta na fase de sandbox tatico e pre-producao. A visao completa esta
registrada em `docs/GAME_DESIGN.md`; a ordem de implementacao esta em
`docs/ROADMAP.md`.

## Abrir o projeto

1. Instale uma versao estavel recente do Godot 4.
2. Importe `project.godot` pelo gerenciador de projetos.
3. Execute a cena principal com `F6` ou o projeto com `F5`.

## Como jogar o sandbox atual

1. Execute o projeto com `F6` ou `F5`.
2. Escolha o idioma e crie uma campanha com qualquer `seed`.
3. Na arena, mova o cursor com `WASD`, setas ou direcional do controle.
4. Pressione `Enter`, clique ou use o botao principal do controle para mover.
5. Aproxime-se de um inimigo e selecione-o para atacar.
6. Pressione `E` ou o botao **Encerrar turno** para permitir a acao inimiga.

O sandbox 0.2.0 possui uma arena isometrica, movimento por celulas, duas unidades
inimigas, turnos alternados, ataques com d20, CA, dano, criticos e registro das
rolagens. Ele e o primeiro recorte do combate, nao a campanha completa.

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
