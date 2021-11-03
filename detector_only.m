% TO DO:
% [ ] enderezar la carta
% [ ] enderezar la imagen
% [ ] reconocer si la carta está volteada

close all, clear all, clc

%% BASIC PROCESSING

% leer la imagen
img_name = 'img/img (10).jpg';
I = imread(img_name,'jpg');
I=imresize(I, 0.5);
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
    current_object = find(etiquetas == i);
    len_current = length(current_object);
    
    if(len_current >= len_card)
        disp(len_current);
        num_cards = num_cards + 1;
    end
end

disp(num_cards);