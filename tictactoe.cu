#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <fstream>

#define EMPTY 0
#define PLAYER1 1
#define PLAYER2 2
#define MAX_N 10

// ======================= DEVICE WIN =======================
__device__ int checkWinDevice(int* board, int player, int N) {

    for(int i = 0; i < N; i++){
        int win = 1;
        for(int j = 0; j < N; j++){
            if(board[i*N + j] != player){
                win = 0; break;
            }
        }
        if(win) return 1;
    }

    for(int j = 0; j < N; j++){
        int win = 1;
        for(int i = 0; i < N; i++){
            if(board[i*N + j] != player){
                win = 0; break;
            }
        }
        if(win) return 1;
    }

    int win = 1;
    for(int i = 0; i < N; i++){
        if(board[i*N + i] != player){
            win = 0; break;
        }
    }
    if(win) return 1;

    win = 1;
    for(int i = 0; i < N; i++){
        if(board[i*N + (N-1-i)] != player){
            win = 0; break;
        }
    }
    if(win) return 1;

    return 0;
}

// ======================= HOST WIN =======================
int checkWinHost(int* board, int player, int N) {

    for(int i = 0; i < N; i++){
        int win = 1;
        for(int j = 0; j < N; j++){
            if(board[i*N + j] != player){
                win = 0; break;
            }
        }
        if(win) return 1;
    }

    for(int j = 0; j < N; j++){
        int win = 1;
        for(int i = 0; i < N; i++){
            if(board[i*N + j] != player){
                win = 0; break;
            }
        }
        if(win) return 1;
    }

    int win = 1;
    for(int i = 0; i < N; i++){
        if(board[i*N + i] != player){
            win = 0; break;
        }
    }
    if(win) return 1;

    win = 1;
    for(int i = 0; i < N; i++){
        if(board[i*N + (N-1-i)] != player){
            win = 0; break;
        }
    }
    if(win) return 1;

    return 0;
}

// ======================= KERNEL =======================
__global__ void evaluateMoves(int* board, int* scores, int player, int N) {

    int idx = threadIdx.x;
    int size = N * N;

    if(idx >= size) return;

    if(board[idx] != EMPTY){
        scores[idx] = -999;
        return;
    }

    int tempBoard[MAX_N * MAX_N];

    for(int i=0;i<size;i++){
        tempBoard[i] = board[i];
    }

    tempBoard[idx] = player;

    if(checkWinDevice(tempBoard, player, N)){
        scores[idx] = 10;
        return;
    }

    int opponent = (player == PLAYER1) ? PLAYER2 : PLAYER1;

    for(int i=0;i<size;i++){
        if(tempBoard[i] == EMPTY){

            tempBoard[i] = opponent;

            if(checkWinDevice(tempBoard, opponent, N)){
                scores[idx] = -10;
                tempBoard[i] = EMPTY;
                return;
            }

            tempBoard[i] = EMPTY;
        }
    }

    scores[idx] = 0;
}

// ======================= BEST MOVE =======================
int getBestMove(int* d_board, int player, int N){

    int size = N*N;

    int *d_scores;
    int *h_scores = (int*)malloc(sizeof(int)*size);

    cudaMalloc(&d_scores, sizeof(int)*size);

    evaluateMoves<<<1, size>>>(d_board, d_scores, player, N);

    cudaMemcpy(h_scores, d_scores, sizeof(int)*size, cudaMemcpyDeviceToHost);

    cudaFree(d_scores);

    int bestScore = -1000;

    for(int i=0;i<size;i++){
        if(h_scores[i] > bestScore){
            bestScore = h_scores[i];
        }
    }

    int candidates[100];
    int count = 0;

    for(int i=0;i<size;i++){
        if(h_scores[i] == bestScore){
            candidates[count++] = i;
        }
    }

    int move = candidates[rand() % count];

    free(h_scores);
    return move;
}

// ======================= PRINT =======================
void printBoard(int* board, std::ofstream &out, int N){

    for(int i=0;i<N;i++){
        for(int j=0;j<N;j++){

            char c = '.';
            if(board[i*N + j] == PLAYER1) c = 'X';
            if(board[i*N + j] == PLAYER2) c = 'O';

            out << c;

            if(j != N-1) out << " ";
        }
        out << "\n";
    }
    out << "-----\n";
}

// ======================= MAIN =======================
int main(int argc, char** argv){

    srand(time(NULL));

    int N = 3; // default

    if(argc > 1){
        N = atoi(argv[1]);
        if(N > MAX_N){
            printf("Max N allowed is %d\n", MAX_N);
            return 0;
        }
    }

    int size = N*N;

    int *h_board = (int*)calloc(size, sizeof(int));
    int *d_board;

    cudaMalloc(&d_board, sizeof(int)*size);
    cudaMemcpy(d_board, h_board, sizeof(int)*size, cudaMemcpyHostToDevice);

    std::ofstream out("output.txt");

    int turn = PLAYER1;

    for(int move=0; move<size; move++){

        int bestMove = getBestMove(d_board, turn, N);

        h_board[bestMove] = turn;

        cudaMemcpy(d_board, h_board, sizeof(int)*size, cudaMemcpyHostToDevice);

        printBoard(h_board, out, N);

        if(checkWinHost(h_board, turn, N)){
            out << "Player " << turn << " wins\n";
            break;
        }

        turn = (turn==PLAYER1)?PLAYER2:PLAYER1;
    }

    out.close();

    cudaFree(d_board);
    free(h_board);

    return 0;
}