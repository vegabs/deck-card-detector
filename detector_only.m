% TO DO:
% [ ] enderezar la carta
% [ ] enderezar la imagen
% [ ] reconocer si la carta está volteada

close all, clear all, clc

%% BASIC PROCESSING

% leer la imagen
img_name = 'img/img (2).jpg';
I = imread(img_name,'jpg');
% I=imresize(I, 0.5);
[M,N,P] = size(I);
% I = double(I);

% mostrar la imagen
figure(1)
imshow(uint8(I));
impixelinfo;

% convertir a HSV
[HSV] = rgb2hsv(I);
H = HSV(:,:,1);
S = HSV(:,:,2);
V = HSV(:,:,3);

H=round(255*H);
S=round(255*S);
V=round(255*V);

% mostrar HSV
figure(2)
subplot(2,2,1);
imshow(uint8(I));
title('Original')
subplot(2,2,2);
imshow(uint8(H));
title('H')
subplot(2,2,3);
imshow(uint8(S));
title('S')
subplot(2,2,4);
imshow(uint8(V));
title('V')
impixelinfo;

% quitar el fondo verde
img_sin_fondo = zeros(M,N);
mask_fondo = find(H <= 60 | H >= 80); % detectar verdes
img_sin_fondo(mask_fondo) = 255;
figure(3)
imshow(uint8(img_sin_fondo));
impixelinfo;

% detectar objetos
len_card = M*N*0.10; % una carta ocupa aprox el 10% de la imagen
num_cards = 0;
[etiquetas, num_objetos] = bwlabel(img_sin_fondo, 8);

for i = 1:num_objetos
    carta_actual = find(etiquetas == i);
    [r,c] = find(etiquetas == i);
    len_carta_actual = length(carta_actual);
    
    if(len_carta_actual >= len_card)
        disp(len_carta_actual);
        num_cards = num_cards + 1;
        
        % extraer el objeto a escala de grises
        carta_actual = I(min(r):max(r),min(c):max(c));
        imshow(uint8(carta_actual));
        impixelinfo;
        
        % procesar la carta en binario: S < 70
        [M_card,N_card,P_card] = size(carta_actual);
        carta_binaria = zeros(M_card,N_card);
        mask_binaria = find(carta_actual <= 70); % detectar verdes
        carta_binaria(mask_binaria) = 255;
        figure();
        hold on;
        imshow(uint8(carta_binaria));
        impixelinfo;
        
        figure();
        hold on;
        
        % contar los objetos de la carta
        [label_carta, num_objetos_carta] = bwlabel(carta_binaria, 8);
        disp(num_objetos_carta);
        disp("----------");
        
    end
end

disp(num_cards);