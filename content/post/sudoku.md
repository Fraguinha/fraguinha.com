---
title: "Sudoku - Sudoku Solver"
description: "Simple sudoku solver using backtracking."
date: 2023-07-12T22:57:00+01:00
draft: false
---

The code used in this post can be found here: [http://github.com/Fraguinha/Sudoku-Solver](http://github.com/Fraguinha/Sudoku-Solver).

# Sudoku

In Sudoku, the goal is to fill a 9 × 9 grid with digits so that each column, each row, and each of the nine 3 × 3 blocks that compose the grid contain all of the digits from 1 to 9.

# Solver

<tr>
<th><input id="0 0" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="0 1" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="0 2" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="0 3" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="0 4" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="0 5" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="0 6" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="0 7" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="0 8" class="text-center w-6 mt-1 mr-1"></input></th>
</tr>
<br>
<tr>
<th><input id="1 0" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="1 1" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="1 2" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="1 3" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="1 4" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="1 5" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="1 6" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="1 7" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="1 8" class="text-center w-6 mt-1 mr-1"></input></th>
</tr>
<br>
<tr>
<th><input id="2 0" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="2 1" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="2 2" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="2 3" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="2 4" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="2 5" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="2 6" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="2 7" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="2 8" class="text-center w-6 mt-1 mr-1"></input></th>
</tr>
<br>
<tr>
<th><input id="3 0" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="3 1" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="3 2" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="3 3" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="3 4" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="3 5" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="3 6" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="3 7" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="3 8" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
</tr>
<br>
<tr>
<th><input id="4 0" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="4 1" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="4 2" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="4 3" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="4 4" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="4 5" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="4 6" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="4 7" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="4 8" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
</tr>
<br>
<tr>
<th><input id="5 0" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="5 1" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="5 2" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="5 3" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="5 4" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="5 5" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="5 6" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="5 7" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="5 8" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
</tr>
<br>
<tr>
<th><input id="6 0" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="6 1" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="6 2" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="6 3" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="6 4" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="6 5" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="6 6" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="6 7" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="6 8" class="text-center w-6 mt-1 mr-1"></input></th>
</tr>
<br>
<tr>
<th><input id="7 0" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="7 1" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="7 2" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="7 3" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="7 4" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="7 5" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="7 6" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="7 7" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="7 8" class="text-center w-6 mt-1 mr-1"></input></th>
</tr>
<br>
<tr>
<th><input id="8 0" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="8 1" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="8 2" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="8 3" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="8 4" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="8 5" class="text-center w-6 mt-1 mr-1 bg-neutral-300 dark:bg-neutral-700"></input></th>
<th><input id="8 6" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="8 7" class="text-center w-6 mt-1 mr-1"></input></th>
<th><input id="8 8" class="text-center w-6 mt-1 mr-1"></input></th>
</tr>

**Note**: missing numbers are represented by 0.

<button onclick="solve()">Solve</button>
<button onclick="reset()">Clear</button>

<script type="module" src="/files/sudoku/main.bc.js"></script>
<script>
let cells = [];

function init() {
  for(let i = 0; i < 9; ++i) {
    for(let j = 0; j < 9; ++j) {
      const id = document.getElementById(`${i} ${j}`);
      cells.push(id);
      id.value = 0;
    }
  }

  // Wikipedia Sudoku
  cells[0].value = 5;
  cells[1].value = 3;
  cells[4].value = 7;
  cells[9].value = 6;
  cells[12].value = 1;
  cells[13].value = 9;
  cells[14].value = 5;
  cells[19].value = 9;
  cells[20].value = 8;
  cells[25].value = 6;
  cells[27].value = 8;
  cells[31].value = 6;
  cells[35].value = 3;
  cells[36].value = 4;
  cells[39].value = 8;
  cells[41].value = 3;
  cells[44].value = 1;
  cells[45].value = 7;
  cells[49].value = 2;
  cells[53].value = 6;
  cells[55].value = 6;
  cells[60].value = 2;
  cells[61].value = 8;
  cells[66].value = 4;
  cells[67].value = 1;
  cells[68].value = 9;
  cells[71].value = 5;
  cells[76].value = 8;
  cells[79].value = 7;
  cells[80].value = 9;
}

function solve() {
  let sudoku = cells.map(input => Number(input.value));

  let solution = SudokuSolver.solve(sudoku);

  solution.map((value, index) => {
    cells[index].value = value;
  });
}

function reset() {
  cells.forEach(input => {
    input.style.color = null;
    input.value = 0;
  });
}

window.onload = init
</script>
