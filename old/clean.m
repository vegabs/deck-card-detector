close all, clear all, clc

corazon = load('corazon.mat').pjc;
trebol = load('trebol.mat').pjc;
espada = load('espada.mat').pjc;
% load('diamante.mat')

% figure, plot(corazon), title("Corazon");
% figure, plot(trebol), title("Trebol");
% figure, plot(espada), title("Espada");


%% CAPTURA

% leer la imagen
img_name = 'new/img (16).jpg';
I = imread(img_name,'jpg');
I = rgb2gray(I);
% I = imrotate(I, 90);
% I=imresize(I, 0.5);
[M,N,P] = size(I);

% mostrar la imagen
figure, imshow(uint8(I));
title("[PASO 1] Imagen en escala de grises");
impixelinfo;

% variables para deteccion
len_card = M*N*0.080; % una carta ocupa aprox el 10% de la imagen
num_cards = 0;

%% IMAGEN BINARIA CON SIMBOLOS Y NUMEROS
% umbralizar la imagen
I1 = zeros(M,N);
mask_1 = find(I >= 130);
I1(mask_1) = 255;
% I_sinfondo = ~I_sinfondo*255;
figure, imshow(uint8(I1));
title("[PASO 2] Imagen binarizada");
impixelinfo;

%% IMAGEN SOLO CUADRADOS BLANCOS
I2 = imdilate(I1, strel('diamond',2));
I2 = imfill(I2, 'holes');
I2 = imerode(I2, strel('diamond', 4));

% detectar objetos
[label_objetos, n_objetos] = bwlabel(I2, 8);

figure, imshow(uint8(I2));
title("[PASO 3] Imagen erode y dilate");
impixelinfo;
propied = regionprops(label_objetos,'BoundingBox', 'Area', 'Image');
hold on
for n=1:size(propied,1)
 rectangle('Position',propied(n).BoundingBox,'EdgeColor','b','LineWidth',2)
end
hold off

%% PROCESAR CADA CARTA
for i = 1:n_objetos
    
    card_now_pre = find(label_objetos == i);    
    [r,c] = find(label_objetos == i);
    len_carta_now = length(card_now_pre);
    
    if(len_carta_now >= len_card)
        
        % hallar el angulo de rotacion
        
        card_now_pre2 = label_objetos == i;
        figure, imshow(card_now_pre2);
        title("[PASO 3.5]")
        impixelinfo;
    
        % carta_now = I2(min(r):max(r),min(c):max(c));
        [label_carta n_carta] = bwlabel(card_now_pre2, 8);
        
        angle = regionprops(label_carta, 'Orientation', 'Extrema');
        theta = sum([angle.Orientation]);
        if theta >= 0
            angle = 90 - theta;
        else
            angle = - 90- theta;
        end
        
        carta_finalx = imrotate(card_now_pre2, angle);
        
        % extraer el pedazo de carta que contiene simbolos
        % carta_final = I1(min(r):max(r),min(c):max(c));
        % carta_final = ~carta_final*255;
        % carta_final = imrotate(carta_final, angle);
        figure, imshow(carta_finalx);
        title("[PASO 4]")
        impixelinfo;
        
        % aplicar mascara
        maskx = card_now_pre2 ./ 255;
        newimg = I1 .* maskx;
        figure, imshow(newimg);
        title("[PASO 4.5]")
        impixelinfo;
        
        numero_carta = 0;
        % extraer el numero de la carta
        [label_final n_final] = bwlabel(carta_finalx, 8);
        
        propied=regionprops(label_final,'BoundingBox');
        hold on
        for n=1:size(propied,1)
            rectangle('Position',propied(n).BoundingBox,'EdgeColor','b','LineWidth',2)
        end
        hold off
        
         for j = 1:n_final
            symbol_actual = find(label_final == j);
            len_symbol = length(symbol_actual);
            
            % contar los numeros
            if(len_symbol > 1000 && len_symbol < 5000)
                numero_carta = numero_carta + 1;
            end
            
            % hallar la funcion de projeccion
            if j == 2
                [rs,cs] = find(label_final == 2);
                symbol_now = carta_final(min(rs)-5:max(rs)+5,min(cs)-5:max(cs)+5);
                figure, imshow(symbol_now);
                impixelinfo;
                
                % senal = sum(symbol_now,2);
                % figure, plot(senal);
                                
                % nombre = strcat( char(randi(+'AZ')) ,'.mat');
                % save(nombre,'pjc');
                
%                 % Find out the length of the shorter matrix
%                 minLength = min(length(senal), length(corazon));
%                 % Removes any extra elements from the longer matrix
%                 senal = senal(1:minLength);
%                 corazon = corazon(1:minLength);

                % comparacion con los demas
                % tipo = hallar_simbolo(senal);
                
                % disp(tipo);
            end
         end
        

        disp("El n??mero de la carta es:");
        disp(numero_carta);
        disp("El simbolo de la carta es:");
        disp();
        
    end
    
end


function tipo = hallar_simbolo(senal)
    be1=corrcoef(interp1(1:numel(corazon),corazon,linspace(1,numel(corazon),numel(senal))),senal);PRO1=mean(be1);compara1=(PRO1(1)+PRO1(2))/2;
    be2=corrcoef(interp1(1:numel(trebol),trebol,linspace(1,numel(trebol),numel(senal))),senal);PRO2=mean(be2);compara2=(PRO2(1)+PRO2(2))/2;
    be3=corrcoef(interp1(1:numel(espada),espada,linspace(1,numel(espada),numel(senal))),senal);PRO3=mean(be3);compara3=(PRO3(1)+PRO3(2))/2;
    % be4=corrcoef(diamante,senal);PRO4=mean(be4);compara4=(PRO4(1)+PRO4(2))/2;

    if compara1>compara2 & compara1>compara3 
        tipo = 'corazon';
    elseif compara2>compara1 & compara2>compara3 
        tipo = 'trebol';
    elseif compara3>compara1 & compara3>compara2 
        tipo = 'espada';
%   elseif compara4>compara1 & compara4>compara2 & compara4>compara3
%       tipo = 'diamante';
    end %%%end del if comparador
end 

