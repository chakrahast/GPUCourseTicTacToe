# 🧠 GPU vs GPU Tic-Tac-Toe (NxN)
### Parallel Decision-Making using CUDA

```
=== TIC TAC TOE GAME (HORIZONTAL VIEW) ===

    Move 1             Move 2             Move 3             Move 4             Move 5             Move 6         

 . | X | . | .      O | X | . | .      O | X | . | .      O | X | . | .      O | X | . | .      O | X | . | .     
 . | . | . | .      . | . | . | .      . | . | . | .      . | . | O | .      . | . | O | .      . | . | O | .     
 . | . | . | .      . | . | . | .      . | . | X | .      . | . | X | .      . | . | X | .      . | . | X | .     
 . | . | . | .      . | . | . | .      . | . | . | .      . | . | . | .      X | . | . | .      X | O | . | .     

   GPU1 (X)           GPU2 (O)           GPU1 (X)           GPU2 (O)           GPU1 (X)           GPU2 (O)        

------------------------------------------------------------------------------------------------------------------

    Move 7             Move 8             Move 9             Move 10            Move 11            Move 12        

 O | X | . | .      O | X | O | .      O | X | O | .      O | X | O | .      O | X | O | .      O | X | O | .     
 . | . | O | .      . | . | O | .      . | . | O | .      . | . | O | .      . | . | O | .      . | O | O | .     
 . | X | X | .      . | X | X | .      . | X | X | X      O | X | X | X      O | X | X | X      O | X | X | X     
 X | O | . | .      X | O | . | .      X | O | . | .      X | O | . | .      X | O | . | X      X | O | . | X     

   GPU1 (X)           GPU2 (O)           GPU1 (X)           GPU2 (O)           GPU1 (X)           GPU2 (O)        

------------------------------------------------------------------------------------------------------------------

    Move 13            Move 14            Move 15            Move 16        

 O | X | O | .      O | X | O | .      O | X | O | .      O | X | O | O     
 . | O | O | .      O | O | O | .      O | O | O | X      O | O | O | X     
 O | X | X | X      O | X | X | X      O | X | X | X      O | X | X | X     
 X | O | X | X      X | O | X | X      X | O | X | X      X | O | X | X     

   GPU1 (X)           GPU2 (O)           GPU1 (X)           GPU2 (O)        

----------------------------------------------------------------------------

```

---

## 📌 1. Project Overview

This project implements a **GPU-accelerated Tic-Tac-Toe system** where two agents (GPU1 and GPU2) compete against each other on an **NxN board**.

Unlike traditional implementations, this system leverages **CUDA parallelism** to evaluate all possible moves simultaneously at each turn.

### Key Features
- Supports **dynamic board size (NxN)** via runtime argument
- Two competing agents (GPU vs GPU)
- **Parallel move evaluation using CUDA**
- Random tie-breaking for non-deterministic gameplay
- Scalable design from small to moderately large boards

---

## 🎯 2. Objective

The goal of this project is to demonstrate:

- How **GPU parallelism** can be applied to decision-making problems
- How to scale a simple game (Tic-Tac-Toe) to larger dimensions
- How multiple agents (GPUs) can simulate competition

---

## 🧮 3. Game Model

### Board Representation
- The board is stored as a **1D array of size N × N**
- Values:
  - `0` → Empty
  - `1` → GPU1 (X)
  - `2` → GPU2 (O)

---

### Win Conditions (Generalized NxN)

A player wins if they occupy:
- Any **row**
- Any **column**
- **Main diagonal**
- **Anti-diagonal**

Win condition = **N consecutive symbols**

---

## ⚙️ 4. System Architecture

### Host (CPU)
- Manages game loop
- Copies data to/from GPU
- Selects best move based on GPU results

### Device (GPU)
- Evaluates all possible moves in parallel
- Computes scores for each move

---

## 🚀 5. Parallel Strategy

At each turn:

1. The current board is copied to the GPU
2. A CUDA kernel is launched with **N² threads**
3. Each thread:
   - Simulates placing a move
   - Evaluates:
     - Win → +10
     - Opponent win next → -10
     - Otherwise → 0
4. CPU selects the best move
5. Random tie-breaking ensures variability

---

### Thread Mapping

| Concept        | Mapping |
|----------------|--------|
| Threads        | One per board cell |
| Total threads  | N² |
| Kernel         | `evaluateMoves` |
| Output         | Score per move |

---

## 🖥️ 6. How to Run

```bash
make clean
make build
./game.exe N
