close all, clear all, clc

% leer la imagen
img_name = 'img/img (9).jpg';
I = imread(img_name,'jpg');
I = rgb2gray(I);
I = imrotate(I, 90);
% I=imresize(I, 0.5);
[M,N,P] = size(I);

% mostrar la imagen
figure(1)
imshow(uint8(I));
title("Imagen en escala de grises");
impixelinfo;

% umbralizar la imagen
I_sinfondo = zeros(M,N);
mask_1 = find(I >= 130); % detectar verdes
I_sinfondo(mask_1) = 255;
% I_sinfondo = ~I_sinfondo*255;
figure(2)
imshow(uint8(I_sinfondo));
title("Imagen en binarizada");
impixelinfo;

I_sinfondo = imdilate(I_sinfondo, strel('diamond',2));
I_sinfondo = imfill(I_sinfondo, 'holes');
I_sinfondo = imerode(I_sinfondo, strel('diamond', 4));

% detectar objetos
len_card = M*N*0.10; % una carta ocupa aprox el 10% de la imagen
num_cards = 0;
[etiquetas, num_objetos] = bwlabel(I_sinfondo, 8);
fig_index = 3;

figure(3)
imshow(uint8(I_sinfondo));
title("Imagen en binarizada luego de erode y dilate");
impixelinfo;
%% areas de imagen
propied = regionprops(etiquetas,'BoundingBox', 'Area', 'Image');
hold on
for n=1:size(propied,1)
 rectangle('Position',propied(n).BoundingBox,'EdgeColor','b','LineWidth',2)
end
hold off

for i = 1:num_objetos
    carta_actual = find(etiquetas == i);
    [r,c] = find(etiquetas == i);
    len_carta_actual = length(carta_actual);
    
    % si el objeto tiene el tamaño de una carta
    if(len_carta_actual >= len_card)
        carta_actual = I_sinfondo(min(r):max(r),min(c):max(c));
        % carta_actual = ~carta_actual*255;
        [label_symbol num_symbol] = bwlabel(carta_actual, 8);
        
        figure(fig_index);
        % imshow(uint8(carta_actual));
        imshow(carta_actual);
        impixelinfo;
        
        fig_index = fig_index+1;
        propied=regionprops(label_symbol,'BoundingBox');
        hold on
        for n=1:size(propied,1)
         rectangle('Position',propied(n).BoundingBox,'EdgeColor','b','LineWidth',2)
        end
        hold off
        
        % rotacion
        angle = regionprops(label_symbol, 'Orientation', 'Extrema');
        theta = sum([angle.Orientation]);
        if theta >= 0
            angle = 90 - theta;
        else
            angle = - 90- theta;
        end
        disp(angle);
        
        carta_rotada = imrotate(carta_actual, angle);
        figure(fig_index);
        % imshow(uint8(carta_actual));
        imshow(carta_rotada);
        impixelinfo;
        fig_index = fig_index+1;
        
    end
end