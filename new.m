close all, clear all, clc;
%%
img_name = 'separados/img (5).jpg';

% a color
I0 = imread(img_name,'jpg');
[M,N,P] = size(I0);
% graficar_img(I0, "Img. Original");

% en gris
I1 = rgb2gray(I0);
graficar_img(I1, "Img. gris");

% binarizar el gris
I2 = zeros(M,N);
mask1 = find(I1 >= 120);
I2(mask1) = 255;
% graficar_img(I2, "Img. gris + binarizada");

% diltate
I3 = imdilate(I2, strel('diamond',4));
% graficar_img(I3, "Dilate");

% encontrar objetos
[label_I3, n_I3] = bwlabel(I3, 8);
for i = 1:n_I3
    objecto = find(label_I3 == i);
    [r,c] = find(label_I3 == i);
    objeto_actual = length(objecto);
    
    if(objeto_actual >= M*N*0.1)
        I4 = (label_I3 == i);
        I5 = I2 .* (I4 ./ 255);
    end
end
graficar_img(I5, "I5");

% invertir la imagen
I6 = ~I5*255;
graficar_img(I6, "I5");

% hallar elementos
I7 = bwareafilt(im2bw(I6,0.5),[50 2000]);
graficar_img(I7*255, "I7");


%%
function graficar_img(img, titulo)
    figure, imshow(img);
    title(titulo);
    impixelinfo;
end