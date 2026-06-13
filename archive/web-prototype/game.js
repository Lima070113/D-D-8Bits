const canvas = document.querySelector("#game-canvas");
const ctx = canvas.getContext("2d");

const TILE = 48;
const COLS = 12;
const ROWS = 9;

const MAP = [
  "############",
  "#..........#",
  "#.###..###.#",
  "#...#......#",
  "###.#.####.#",
  "#...#......#",
  "#.#####.##.#",
  "#..........#",
  "############",
];

const ENEMY_TEMPLATES = {
  goblin: { name: "Goblin das Cinzas", hp: 12, defense: 11, attack: 3, damage: 6, xp: 12 },
  skeleton: { name: "Esqueleto Rúnico", hp: 16, defense: 12, attack: 4, damage: 7, xp: 16 },
  guardian: { name: "Guardião do Eco", hp: 28, defense: 14, attack: 5, damage: 8, xp: 30 },
};

const initialEnemies = [
  { type: "goblin", x: 5, y: 1 },
  { type: "skeleton", x: 9, y: 3 },
  { type: "goblin", x: 3, y: 7 },
  { type: "guardian", x: 9, y: 7 },
];

const ui = {
  hp: document.querySelector("#hp"),
  maxHp: document.querySelector("#max-hp"),
  hpBar: document.querySelector("#hp-bar"),
  xp: document.querySelector("#xp"),
  nextXp: document.querySelector("#next-xp"),
  xpBar: document.querySelector("#xp-bar"),
  level: document.querySelector("#level"),
  attack: document.querySelector("#attack"),
  defense: document.querySelector("#defense"),
  potions: document.querySelector("#potions"),
  keyStatus: document.querySelector("#key-status"),
  questText: document.querySelector("#quest-text"),
  statusText: document.querySelector("#status-text"),
  log: document.querySelector("#adventure-log"),
  combatCard: document.querySelector("#combat-card"),
  enemyName: document.querySelector("#enemy-name"),
  enemyHp: document.querySelector("#enemy-hp"),
  enemyMaxHp: document.querySelector("#enemy-max-hp"),
  enemyHpBar: document.querySelector("#enemy-hp-bar"),
  attackButton: document.querySelector("#attack-button"),
  potionButton: document.querySelector("#potion-button"),
  endScreen: document.querySelector("#end-screen"),
  endKicker: document.querySelector("#end-kicker"),
  endTitle: document.querySelector("#end-title"),
  endMessage: document.querySelector("#end-message"),
};

let state;

function createState() {
  return {
    hero: {
      x: 1,
      y: 1,
      hp: 24,
      maxHp: 24,
      attack: 5,
      defense: 13,
      potions: 2,
      xp: 0,
      nextXp: 30,
      level: 1,
      hasKey: false,
    },
    enemies: initialEnemies.map((enemy, id) => ({
      ...ENEMY_TEMPLATES[enemy.type],
      ...enemy,
      id,
      maxHp: ENEMY_TEMPLATES[enemy.type].hp,
    })),
    key: { x: 1, y: 7, collected: false },
    portal: { x: 10, y: 1 },
    combatEnemyId: null,
    finished: false,
  };
}

function rollDie(sides) {
  return Math.floor(Math.random() * sides) + 1;
}

function addLog(message) {
  const item = document.createElement("li");
  item.textContent = message;
  ui.log.prepend(item);

  while (ui.log.children.length > 12) {
    ui.log.lastElementChild.remove();
  }
}

function getEnemy() {
  return state.enemies.find((enemy) => enemy.id === state.combatEnemyId) ?? null;
}

function updateUI() {
  const { hero } = state;
  ui.hp.textContent = hero.hp;
  ui.maxHp.textContent = hero.maxHp;
  ui.hpBar.style.width = `${Math.max(0, (hero.hp / hero.maxHp) * 100)}%`;
  ui.xp.textContent = hero.xp;
  ui.nextXp.textContent = hero.nextXp;
  ui.xpBar.style.width = `${(hero.xp / hero.nextXp) * 100}%`;
  ui.level.textContent = hero.level;
  ui.attack.textContent = `+${hero.attack}`;
  ui.defense.textContent = hero.defense;
  ui.potions.textContent = hero.potions;
  ui.keyStatus.textContent = hero.hasKey ? "SIM" : "NÃO";
  ui.potionButton.disabled = hero.potions === 0 || hero.hp === hero.maxHp;

  const enemy = getEnemy();
  ui.combatCard.classList.toggle("hidden", !enemy);

  if (enemy) {
    ui.enemyName.textContent = enemy.name;
    ui.enemyHp.textContent = Math.max(0, enemy.hp);
    ui.enemyMaxHp.textContent = enemy.maxHp;
    ui.enemyHpBar.style.width = `${Math.max(0, (enemy.hp / enemy.maxHp) * 100)}%`;
    ui.statusText.textContent = `Combate contra ${enemy.name}!`;
  } else if (!state.finished) {
    ui.statusText.textContent = "Explore com WASD ou as setas.";
  }

  if (hero.hasKey && state.enemies.some((enemy) => enemy.type === "guardian")) {
    ui.questText.textContent = "A chave é sua. Derrote o guardião do portal.";
  } else if (hero.hasKey) {
    ui.questText.textContent = "O caminho está livre. Alcance o portal arcano.";
  }
}

function drawTile(x, y, wall) {
  const px = x * TILE;
  const py = y * TILE;

  ctx.fillStyle = wall ? "#1a1c25" : "#292b31";
  ctx.fillRect(px, py, TILE, TILE);

  ctx.fillStyle = wall ? "#292d3a" : "#33363c";
  ctx.fillRect(px + 3, py + 3, TILE - 6, TILE - 6);

  if (wall) {
    ctx.fillStyle = "#161820";
    ctx.fillRect(px + 4, py + 22, TILE - 8, 4);
    ctx.fillRect(px + 22, py + 4, 4, 18);
  } else {
    ctx.fillStyle = "#272a30";
    ctx.fillRect(px + 8, py + 10, 4, 4);
    ctx.fillRect(px + 34, py + 32, 5, 3);
  }
}

function drawMap() {
  MAP.forEach((row, y) => {
    [...row].forEach((tile, x) => drawTile(x, y, tile === "#"));
  });
}

function drawKey() {
  if (state.key.collected) return;
  const x = state.key.x * TILE;
  const y = state.key.y * TILE;
  ctx.fillStyle = "#e0ad3b";
  ctx.fillRect(x + 12, y + 20, 22, 8);
  ctx.fillRect(x + 28, y + 15, 7, 18);
  ctx.fillRect(x + 8, y + 16, 12, 16);
  ctx.fillStyle = "#292b31";
  ctx.fillRect(x + 11, y + 20, 6, 7);
}

function drawPortal() {
  const x = state.portal.x * TILE;
  const y = state.portal.y * TILE;
  ctx.fillStyle = "#15131d";
  ctx.fillRect(x + 8, y + 5, 32, 38);
  ctx.fillStyle = state.hero.hasKey ? "#9d6dcc" : "#4d3b5e";
  ctx.fillRect(x + 12, y + 9, 24, 30);
  ctx.fillStyle = "#17101f";
  ctx.fillRect(x + 17, y + 14, 14, 20);
  ctx.fillStyle = "#d69cff";
  ctx.fillRect(x + 21, y + 18, 5, 5);
}

function drawEnemy(enemy) {
  const x = enemy.x * TILE;
  const y = enemy.y * TILE;
  const isGuardian = enemy.type === "guardian";
  ctx.fillStyle = isGuardian ? "#9b3f43" : "#56734d";
  ctx.fillRect(x + 12, y + 13, 24, 24);
  ctx.fillStyle = isGuardian ? "#d8c6a0" : "#9cbc75";
  ctx.fillRect(x + 16, y + 8, 16, 12);
  ctx.fillStyle = "#17191f";
  ctx.fillRect(x + 18, y + 12, 4, 4);
  ctx.fillRect(x + 27, y + 12, 4, 4);
  ctx.fillStyle = "#6b4b36";
  ctx.fillRect(x + 8, y + 22, 6, 20);
  ctx.fillRect(x + 34, y + 22, 6, 20);
}

function drawHero() {
  const x = state.hero.x * TILE;
  const y = state.hero.y * TILE;
  ctx.fillStyle = "#d9d3bd";
  ctx.fillRect(x + 15, y + 7, 18, 15);
  ctx.fillStyle = "#3d526b";
  ctx.fillRect(x + 12, y + 20, 24, 21);
  ctx.fillStyle = "#17191f";
  ctx.fillRect(x + 19, y + 12, 4, 4);
  ctx.fillStyle = "#e0ad3b";
  ctx.fillRect(x + 8, y + 23, 5, 18);
}

function draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawMap();
  drawPortal();
  drawKey();
  state.enemies.forEach(drawEnemy);
  drawHero();
}

function isWalkable(x, y) {
  return x >= 0 && y >= 0 && x < COLS && y < ROWS && MAP[y][x] !== "#";
}

function enemyAt(x, y) {
  return state.enemies.find((enemy) => enemy.x === x && enemy.y === y);
}

function moveHero(dx, dy) {
  if (state.finished || getEnemy()) return;

  const nextX = state.hero.x + dx;
  const nextY = state.hero.y + dy;
  if (!isWalkable(nextX, nextY)) {
    addLog("Uma parede ancestral bloqueia o caminho.");
    return;
  }

  const enemy = enemyAt(nextX, nextY);
  if (enemy) {
    state.combatEnemyId = enemy.id;
    addLog(`${enemy.name} avança! Role iniciativa!`);
    updateUI();
    draw();
    return;
  }

  state.hero.x = nextX;
  state.hero.y = nextY;

  if (nextX === state.key.x && nextY === state.key.y && !state.key.collected) {
    state.key.collected = true;
    state.hero.hasKey = true;
    addLog("Você encontrou a Chave Rúnica!");
  }

  if (nextX === state.portal.x && nextY === state.portal.y) {
    tryPortal();
  }

  updateUI();
  draw();
}

function tryPortal() {
  const guardianAlive = state.enemies.some((enemy) => enemy.type === "guardian");
  if (!state.hero.hasKey) {
    addLog("O portal está selado. Falta uma chave.");
    return;
  }
  if (guardianAlive) {
    addLog("A presença do guardião mantém o portal fechado.");
    return;
  }
  finishGame(true);
}

function heroAttack() {
  const enemy = getEnemy();
  if (!enemy || state.finished) return;

  const roll = rollDie(20);
  const total = roll + state.hero.attack;

  if (roll === 1 || (roll !== 20 && total < enemy.defense)) {
    addLog(`Ataque: d20 ${roll} + ${state.hero.attack}. Você errou.`);
  } else {
    let damage = rollDie(8) + 2;
    const critical = roll === 20;
    if (critical) damage += rollDie(8);
    enemy.hp -= damage;
    addLog(
      `Ataque: d20 ${roll} + ${state.hero.attack}. ${critical ? "CRÍTICO! " : ""}${damage} de dano.`,
    );
  }

  if (enemy.hp <= 0) {
    defeatEnemy(enemy);
  } else {
    enemyTurn(enemy);
  }

  updateUI();
  draw();
}

function enemyTurn(enemy) {
  const roll = rollDie(20);
  const total = roll + enemy.attack;
  if (roll === 1 || (roll !== 20 && total < state.hero.defense)) {
    addLog(`${enemy.name}: d20 ${roll} + ${enemy.attack}. Errou você.`);
    return;
  }

  let damage = rollDie(enemy.damage);
  if (roll === 20) damage += rollDie(enemy.damage);
  state.hero.hp = Math.max(0, state.hero.hp - damage);
  addLog(`${enemy.name}: d20 ${roll} + ${enemy.attack}. Você sofre ${damage} de dano.`);

  if (state.hero.hp <= 0) {
    finishGame(false);
  }
}

function usePotion() {
  const enemy = getEnemy();
  const { hero } = state;
  if (!enemy || hero.potions <= 0 || hero.hp === hero.maxHp) return;

  const healing = Math.min(hero.maxHp - hero.hp, rollDie(8) + 4);
  hero.hp += healing;
  hero.potions -= 1;
  addLog(`Você recupera ${healing} PV com uma poção.`);
  enemyTurn(enemy);
  updateUI();
  draw();
}

function defeatEnemy(enemy) {
  addLog(`${enemy.name} foi derrotado. +${enemy.xp} XP.`);
  state.hero.x = enemy.x;
  state.hero.y = enemy.y;
  state.hero.xp += enemy.xp;
  state.enemies = state.enemies.filter((item) => item.id !== enemy.id);
  state.combatEnemyId = null;
  checkLevelUp();
}

function checkLevelUp() {
  const { hero } = state;
  if (hero.xp < hero.nextXp) return;

  hero.xp -= hero.nextXp;
  hero.level += 1;
  hero.nextXp += 20;
  hero.maxHp += 8;
  hero.hp = hero.maxHp;
  hero.attack += 1;
  hero.defense += 1;
  addLog(`NÍVEL ${hero.level}! Seus atributos aumentaram e seus PV foram restaurados.`);
}

function finishGame(victory) {
  state.finished = true;
  state.combatEnemyId = null;
  ui.endScreen.classList.remove("hidden");
  ui.endKicker.textContent = victory ? "MISSÃO CONCLUÍDA" : "FIM DA JORNADA";
  ui.endTitle.textContent = victory ? "VITÓRIA!" : "VOCÊ CAIU";
  ui.endMessage.textContent = victory
    ? "A Cripta do Eco foi vencida. Bytefall ainda guarda muitos segredos."
    : "Os dados foram cruéis desta vez. Reúna coragem e tente novamente.";
  updateUI();
}

function resetGame() {
  state = createState();
  ui.log.innerHTML = "";
  ui.endScreen.classList.add("hidden");
  addLog("A aventura começa. Encontre a chave rúnica.");
  updateUI();
  draw();
}

const movementKeys = {
  ArrowUp: [0, -1],
  w: [0, -1],
  W: [0, -1],
  ArrowDown: [0, 1],
  s: [0, 1],
  S: [0, 1],
  ArrowLeft: [-1, 0],
  a: [-1, 0],
  A: [-1, 0],
  ArrowRight: [1, 0],
  d: [1, 0],
  D: [1, 0],
};

window.addEventListener("keydown", (event) => {
  const movement = movementKeys[event.key];
  if (!movement) return;
  event.preventDefault();
  moveHero(...movement);
});

document.querySelectorAll("[data-move]").forEach((button) => {
  const directions = {
    up: [0, -1],
    down: [0, 1],
    left: [-1, 0],
    right: [1, 0],
  };
  button.addEventListener("click", () => moveHero(...directions[button.dataset.move]));
});

ui.attackButton.addEventListener("click", heroAttack);
ui.potionButton.addEventListener("click", usePotion);
document.querySelector("#restart-button").addEventListener("click", resetGame);
document.querySelector("#play-again-button").addEventListener("click", resetGame);

resetGame();
