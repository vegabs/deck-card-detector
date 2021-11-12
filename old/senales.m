close all, clear all, clc;

jsenal = load('A.mat').senal_letra;
ksenal = load('W.mat').senal_letra;
qsenal = load('Y.mat').senal_letra;
asenal = load('YA.mat').senal_letra;

trebol = load('Qs.mat').senal_simbolo;
espada = load('Cs.mat').senal_simbolo;
corazon = load('Hs.mat').senal_simbolo;
diamante = load('Ec.mat').senal_simbolo;

% figure, plot(jsenal), title("j");
% figure, plot(ksenal), title("k");
% figure, plot(qsenal), title("q");
% figure, plot(asenal), title("a");

figure, plot(trebol), title("trebol");
figure, plot(espada), title("espada");
figure, plot(corazon), title("corazon");
figure, plot(diamante), title("diamante");
