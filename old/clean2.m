close all, clear all, clc;

%% SENALES
jsenal = load('../signals/j.mat').senal_letra;
ksenal = load('../signals/k.mat').senal_letra;
qsenal = load('../signals/q.mat').senal_letra;
asenal = load('../signals/a.mat').senal_letra;

trebol = load('../signals/trebol.mat').senal_simbolo;
espada = load('../signals/espada.mat').senal_simbolo;
corazon = load('../signals/corazon.mat').senal_simbolo;
diamante = load('../signals/diamante.mat').senal_simbolo;

%% CAPTURA
img_name = '../new/img (15).jpg';
I0 = imread(img_name,'jpg');
I0 = rgb2gray(I0);
% I = imrotate(I, 90);
% I=imresize(I, 0.5);
[M,N,P] = size(I0);

% graficar_img(I0, "[PASO 1] Imagen original en escala de grises");

%% VARIABLES DE DETECCION
len_card = M*N*0.080; % una carta ocupa aprox el 10% de la imagen
num_cards = 0;

%% IMAGEN BINARIA CON SIMBOLOS Y NUMEROS
% umbralizar la imagen
I1 = zeros(M,N);
mask1 = find(I0 >= 130);
I1(mask1) = 255;
% I_sinfondo = ~I_sinfondo*255;
% graficar_img(I1, "[PASO 2] Imagen binarizada");

%% IMAGEN SOLO CUADRADOS BLANCOS
I2 = imdilate(I1, strel('diamond',2));
I2 = imfill(I2, 'holes');
I2 = imerode(I2, strel('diamond', 4));

% graficar_img(I2, "[PASO 3] Solo cuadrados blancos");

%% DETECTAR LOS CUADRADOS BLANCOS USANDO BWLABEL Y I2
[label_I2, n_I2] = bwlabel(I2, 8);

% iterar entre cada cuadrado blanco
cartas = {};
for i = 1:n_I2
    
    % generar las imagenes con cada cuadrado solo
    I3 = (label_I2 == i);
    I4 = I1 .* (I3 ./ 255);
    % graficar_img(I3, "[PASO 4] Misma resolucion pero solo un objeto");
    % graficar_img(I4, "[PASO 5] Misma resolucion pero con simbolos y cuadrado");
    
    % hallar el angulo de rotacion
    [label_I3 n_I3] = bwlabel(I3, 8);
    angulo = hallar_angulo(label_I3);
    
    % rotar ambas imagenes
    I3r = imrotate(I3, angulo);
    I4r = imrotate(I4, angulo);
    % graficar_img(I3r, "[PASO 4 ROT] Misma resolucion pero solo un objeto");
    % graficar_img(I4r, "[PASO 5 ROT] Misma resolucion pero con simbolos y cuadrado");
    
    % hallar la carta en imagen rotada
    [label_I3r n_I3r] = bwlabel(I3r, 8);
    [r,c] = find(label_I3r == 1);
    dt = 10;
    carta_bw = I4r(min(r)+dt:max(r)-dt,min(c)+dt:max(c)-dt);
    % graficar_img(carta_bw, "[PASO 6] Carta final yay!");
    
    % detectar si la carta es J K Q o normal
    [Mcarta, Ncarta, P] = size(carta_bw);
    por_franja = 0.15 * Ncarta;
    franja = carta_bw(1: end, 1: por_franja);
    franja_numero = franja(1: int8(0.14*Mcarta), 1: end);
    franja_numero = ~franja_numero*255;
    % graficar_img(franja, "[PASO 7] Franja");
    
    [label_franja n_franja] = bwlabel(franja_numero, 8);    
    [rl,cl] = find(label_franja == 1);
    m_letra = franja_numero(min(rl):max(rl), min(cl):max(cl));
    
    % graficar_img(m_letra, "[PASO 8] Franja en letra/numero");
    
    senal_letra = sum(m_letra, 1);
    % figure, plot(senal_letra), title("Señal de la letra/numero");
    
    % [letra, num_carta] = hallar_letra(senal_letra, jsenal, ksenal, qsenal, asenal);
    % disp(letra);
    % disp(num_carta);
    
%     nombre = strcat( char(randi(+'AZ')) ,'k.mat');
%     save(nombre,'senal_letra');
%     disp(nombre);
    
    % hallar simbolo
    franja_simbolo = franja(int8(0.14*Mcarta): int8(0.27*Mcarta), 1: end);
    franja_simbolo = ~franja_simbolo*255;
    [label_franjas n_franjas] = bwlabel(franja_simbolo, 8);    
    [rl,cl] = find(label_franjas == 1);
    m_simbolo = franja_simbolo(min(rl):max(rl), min(cl):max(cl));
    
    % graficar_img(m_simbolo, "[PASO 9] Franja en simbolo");
    
    senal_simbolo = sum(m_simbolo, 2);
    % figure, plot(senal_simbolo), title("Señal del simbolo");
    simbolo = hallar_simbolo(senal_simbolo, corazon, espada, trebol, diamante);
    
%     nombre = strcat( char(randi(+'AZ')) ,'c.mat');
%     save(nombre,'senal_simbolo');
%     disp(nombre);
    
    % aqui sabes que no es una letra entonces ya haces el otro proceso
%     if(letra == "null")
%         num_carta = hallar_numero(carta_bw);
%     end
    
%     disp("CARTA -------");
%     disp(num_carta);
%     disp(simbolo);
%     disp("------------\n");
    
    % primero hallar el numero de cartas
    num_carta_prev = hallar_numero(carta_bw);
    [letra, num_carta_prev2] = hallar_letra(senal_letra, jsenal, ksenal, qsenal, asenal);
    
    if (letra ~= 'A')
        if(num_carta_prev >= 12)
            num_carta = num_carta_prev2;
        else
            num_carta = num_carta_prev;
        end
    else
        num_carta = num_carta_prev2;
    end
    
    % añadir elementos al struct
    cartas(i).num_carta = num_carta;
    cartas(i).simbolo = simbolo;
    cartas(i).imagen = carta_bw;

end

% disp(cartas);
figure;
for i = 1:length(cartas)
    subplot(1,length(cartas), i);
    titulo = [int2str(cartas(i).num_carta) '-' cartas(i).simbolo];
    imshow(cartas(i).imagen);
    title(titulo);
    impixelinfo;
end

