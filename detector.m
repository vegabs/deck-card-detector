function varargout = detector(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @detector_OpeningFcn, ...
                   'gui_OutputFcn',  @detector_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function detector_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for detector
handles.output = hObject;

% inicializar la camara
closepreview();
handles.video = videoinput('winvideo', 2, 'RGB24_1280x720');
% handles.video = videoinput('winvideo', 1);
axes(handles.axesCaptura);
HI = image(zeros(720,1280,3),'Parent',handles.axesCaptura);
preview(handles.video, HI);
% preview(handles.video);
% set axes de captura
axes(handles.axesCaptura);
axis off;

% Update handles structure
guidata(hObject, handles);

function varargout = detector_OutputFcn(hObject, eventdata, handles) 
set(handles.tablaResultado,'data', []);
% Get default command line output from handles structure
varargout{1} = handles.output;

function btnCaptura_Callback(hObject, eventdata, handles)
handles.my_img = getsnapshot(handles.video);
axes(handles.axesImagen);
imshow(uint8(handles.my_img));
% img_name = "img_" + datestr(now,'yyyy-mm-dd_hh-MM-ss.jpg');
% imwrite(handles.my_img, char(img_name));

% Update handles structure
guidata(hObject, handles);

function btnArchivo_Callback(hObject, eventdata, handles)
[my_filename, my_folder] = uigetfile('*.jpg');
my_file = my_folder + "" + my_filename; 
handles.my_img = imread(my_file);
handles.my_img_axes = handles.my_img;

% mostrar la imagen en el axes
set(handles.axesImagen,'Units','pixels');
resizePos = get(handles.axesImagen,'Position');
% handles.my_img_axes = imresize(handles.my_img_axes, [resizePos(3) resizePos(3)]);
axes(handles.axesImagen);
imshow(handles.my_img_axes);
set(handles.axesImagen,'Units','normalized');

% actualizar variables
guidata(hObject,handles);

function btnProcesar_Callback(hObject, eventdata, handles)

%% SENALES
jsenal = load('signals/j.mat').senal_letra;
ksenal = load('signals/k.mat').senal_letra;
qsenal = load('signals/q.mat').senal_letra;
asenal = load('signals/a.mat').senal_letra;

trebol = load('signals/trebol.mat').senal_simbolo;
espada = load('signals/espada.mat').senal_simbolo;
corazon = load('signals/corazon.mat').senal_simbolo;
diamante = load('signals/diamante.mat').senal_simbolo;

%% CAPTURA
I0 = handles.my_img;
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
    franja_numero = franja(1: round(0.14*Mcarta), 1: end);
    franja_numero = ~franja_numero*255;
    % graficar_img(franja, "[PASO 7] Franja");
    
    [label_franja n_franja] = bwlabel(franja_numero, 8);    
    [rl,cl] = find(label_franja == 1);
    m_letra = franja_numero(min(rl):max(rl), min(cl):max(cl));
    % m_letra = imdilate(m_letra, strel('diamond', 2));
    % m_letra = imerode(m_letra, strel('diamond', 2));
    
    % graficar_img(m_letra, "[PASO 8] Franja en letra/numero");
    
    senal_letra = sum(m_letra, 1);
    % figure, plot(senal_letra), title("Señal de la letra/numero");
      
%     nombre = strcat( char(randi(+'AZ')) ,'K.mat');
%     save(nombre,'senal_letra');
%     disp(nombre);
    
    % hallar simbolo
    franja_simbolo = franja(round(0.14*Mcarta): round(0.27*Mcarta), 1: end);
    franja_simbolo = ~franja_simbolo*255;
    [label_franjas n_franjas] = bwlabel(franja_simbolo, 8);    
    [rl,cl] = find(label_franjas == 1);
    m_simbolo = franja_simbolo(min(rl):max(rl), min(cl):max(cl));
    
    % graficar_img(m_simbolo, "[PASO 9] Franja en simbolo");
    
    senal_simbolo = sum(m_simbolo, 2);
    cartas(i).senal_simbolo = senal_simbolo;
    
    % figure, plot(senal_simbolo), title("Señal del simbolo");
    simbolo = hallar_simbolo(senal_simbolo, corazon, espada, trebol, diamante);
    
%     nombre = strcat( char(randi(+'AZ')) ,'c.mat');
%     save(nombre,'senal_simbolo');
%     disp(nombre);

    % primero hallar el numero de cartas
    num_carta_prev = hallar_numero(carta_bw);
    disp(num_carta_prev);
    [letra, num_carta_prev2] = hallar_letra(senal_letra, jsenal, ksenal, qsenal, asenal);
        
    % disp(letra);
    % disp(num_carta);
    
    if (letra ~= 'A')
        if(str2num(num_carta_prev) >= 12)
            disp("Aqui 1");
            cartas(i).num_carta = num_carta_prev2;
        else
            disp("Aqui 2");
            cartas(i).num_carta = num_carta_prev;
        end
    else
        disp("Aqui 3");        
        cartas(i).num_carta = num_carta_prev2;
    end
    
    if(simbolo == "Volteada")
        letra = ' ';
        cartas(i).num_carta = ' ';
    end
    
%     disp("CARTA -------");
%     disp(num_carta);
%     disp(simbolo);
%     disp("------------\n");
    
    % añadir elementos al struct
    
    cartas(i).simbolo = simbolo;
    cartas(i).imagen = carta_bw;

end

% disp(cartas);

% figure;
% for i = 1:length(cartas)
%     subplot(1,length(cartas), i);
%     titulo = [int2str(cartas(i).num_carta) '-' cartas(i).simbolo];
%     imshow(cartas(i).imagen);
%     title(titulo);
%     impixelinfo;
% end

% llenar la tabla
set(handles.tablaResultado,'data', []);
data = get(handles.tablaResultado, 'data');
for j = 1:length(cartas)
    data = [data ; [{cartas(j).num_carta} {cartas(j).simbolo}]];
end
set(handles.tablaResultado,'data',data);

% llenar ui panel
panhandle = handles.uipanel1;
for i = 1:length(cartas)
    subplot(1,length(cartas), i, 'Parent', panhandle);
    titulo = [cartas(i).num_carta ' - ' cartas(i).simbolo];
    imshow(cartas(i).imagen);
    title(titulo, 'Color','white');    
    impixelinfo;
end

panhandle2 = handles.uipanel3;
for i = 1:length(cartas)
    subplot(length(cartas),1, i, 'Parent', panhandle2);
    titulo = [cartas(i).num_carta ' - ' cartas(i).simbolo];
    plot(cartas(i).senal_simbolo);
    title(titulo, 'Color','white');
end

% actualizar variables
guidata(hObject,handles);

%% FUNCIONES
function graficar_img(img, titulo)
figure, imshow(img);
title(titulo);
impixelinfo;

function angle = hallar_angulo(label)
angle = regionprops(label, 'Orientation', 'Extrema');
theta = sum([angle.Orientation]);
if theta >= 0
    angle = 90 - theta;
else
    angle = - 90- theta;
end

function [letra, valor] = hallar_letra(senal, jota, ka, qu, a)

jota = interp1(1:numel(jota),jota,linspace(1,numel(jota),numel(senal)));
ka = interp1(1:numel(ka),ka,linspace(1,numel(ka),numel(senal)));
qu = interp1(1:numel(qu),qu,linspace(1,numel(qu),numel(senal)));
a = interp1(1:numel(a),a,linspace(1,numel(a),numel(senal)));

aj = corrcoef(jota,senal); mj = mean(aj); accj = (mj(1)+mj(2))/2;
ak = corrcoef(ka,senal); mk = mean(ak); acck = (mk(1)+mk(2))/2;
aq = corrcoef(qu,senal); mq = mean(aq); accq = (mq(1)+mq(2))/2;
aa = corrcoef(a,senal); ma = mean(aa); acca = (ma(1)+ma(2))/2;

porcentaje = 0.83;
if accj >= porcentaje
    letra = 'J';
    valor = '11';
elseif acck >= porcentaje
    letra = 'K';
    valor = '13';
elseif accq >= porcentaje
    letra = 'Q';
    valor = '12';
elseif acca >= porcentaje
    letra = 'A';
    valor = '14';
else
    letra = "n";
    valor = '0';
end

function [simbolo] = hallar_simbolo(senal, corazon, espada, trebol, diamante)  
simbolo = '';

corazon = interp1(1:numel(corazon),corazon,linspace(1,numel(corazon),numel(senal)));
trebol = interp1(1:numel(trebol),trebol,linspace(1,numel(trebol),numel(senal)));
espada = interp1(1:numel(espada),espada,linspace(1,numel(espada),numel(senal)));
diamante = interp1(1:numel(diamante),diamante,linspace(1,numel(diamante),numel(senal)));

be1=corrcoef(corazon,senal);PRO1=mean(be1);compara1=(PRO1(1)+PRO1(2))/2;
be2=corrcoef(trebol,senal);PRO2=mean(be2);compara2=(PRO2(1)+PRO2(2))/2;
be3=corrcoef(espada,senal);PRO3=mean(be3);compara3=(PRO3(1)+PRO3(2))/2;
be4=corrcoef(diamante,senal);PRO4=mean(be4);compara4=(PRO4(1)+PRO4(2))/2;

if compara1>compara2 & compara1>compara3 & compara1>compara4 & compara1 >= 0.90
 simbolo = 'Corazon ♥';
elseif compara2>compara1 & compara2>compara3 & compara2>compara4 & compara2 >= 0.90
 simbolo = 'Trebol ♣';
elseif compara3>compara1 & compara3>compara2 & compara3>compara4 & compara3 >= 0.90
 simbolo = 'Espada ♠';
elseif compara4>compara1 & compara4>compara2 & compara4>compara3 & compara4 >= 0.90
 simbolo = 'Diamante ♦';
else
    simbolo = 'Volteada';
end

function valor = hallar_numero(img)
[M, N, P] = size(img);
borde = 0.15*N;
borde2 = (1 - 0.15)*N;

% graficar_img(img, "Carta1");

img1 = ~img*255;
% graficar_img(img1, "Carta2");

img2 = img1(1: end, borde: borde2);
% graficar_img(img2, "Carta3");

[label n] = bwlabel(img2, 8);

%valor = n;
valor = 0;

for i = 1:n
    obj = find(label == i);
    len = length(obj);
    if(len >= 20)
        valor = valor + 1;
    end
end

valor = int2str(valor);
