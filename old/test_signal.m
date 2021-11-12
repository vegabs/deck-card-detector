close all, clear all, clc;

jsenal = load('YK.mat').senal_letra;
ksenal = load('VK.mat').senal_letra;
qsenal = load('JK.mat').senal_letra;
asenal = load('GK.mat').senal_letra;
asenal2 = load('../signals/k.mat').senal_letra;

figure,
subplot(5,1,1)
plot(jsenal), title("j");
subplot(5,1,2)
plot(ksenal), title("k");
subplot(5,1,3)
plot(qsenal), title("q");
subplot(5,1,4)
plot(asenal), title("a");
subplot(5,1,5)
plot(asenal2), title("verdadera k");