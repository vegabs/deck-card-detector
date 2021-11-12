%% PASOS
% [x] capturar la imagen 
% [x] convertir a escala de grises
% [x] binarizar
% [x] detectar objetos para los numeros
% [ ] rotar para hallar los simbolos

close all, clear all, clc

% leer la imagen
img_name = 'img/img (10).jpg';
I = imread(img_name,'jpg');
I =rgb2gray(I);
% I=imresize(I, 0.5);
[M,N,P] = size(I);

% mostrar la imagen
% figure(1)
% imshow(uint8(I));
% impixelinfo;

% umbralizar la imagen
I_sinfondo = zeros(M,N);
mask_1 = find(I >= 130); % detectar verdes
I_sinfondo(mask_1) = 255;
% I_sinfondo = ~I_sinfondo*255;
figure(2)
imshow(uint8(I_sinfondo));
impixelinfo;


% detectar objetos
len_card = M*N*0.10; % una carta ocupa aprox el 10% de la imagen
num_cards = 0;
[etiquetas, num_objetos] = bwlabel(I_sinfondo, 8);
fig_index = 3;
for i = 1:num_objetos
    carta_actual = find(etiquetas == i);
    [r,c] = find(etiquetas == i);
    len_carta_actual = length(carta_actual);
    
    % si el objeto tiene el tamaño de una carta
    if(len_carta_actual >= len_card)
        disp(len_carta_actual);
        num_cards = num_cards + 1;
        
        carta_actual = I_sinfondo(min(r)-10:max(r)+10,min(c)-10:max(c)+10);
        carta_actual = ~carta_actual*255;
        [label_symbol num_symbol] = bwlabel(carta_actual, 8);
        
        figure(fig_index);
        imshow(uint8(carta_actual));
        impixelinfo;
        fig_index = fig_index+1;
        propied=regionprops(label_symbol,'BoundingBox');
        hold on
        for n=1:size(propied,1)
         rectangle('Position',propied(n).BoundingBox,'EdgeColor','b','LineWidth',2)
        end
        hold off

        % contar los symbolos
        numero_carta = 0;
        for j = 1:num_symbol
            symbol_actual = find(label_symbol == j);
            len_symbol = length(symbol_actual);
            
            if(len_symbol > 1000 && len_symbol < 5000)
                numero_carta = numero_carta + 1;
            end
        end
        
        disp("El número de la carta es:");
        disp(numero_carta);
    end
end
