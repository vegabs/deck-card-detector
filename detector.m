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


% --- Executes just before detector is made visible.
function detector_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for detector
handles.output = hObject;

% inicializar la camara
closepreview();
handles.video = videoinput('winvideo', 1);
axes(handles.axesCaptura);
HI = image(zeros(720,1280,3),'Parent',handles.axesCaptura);
preview(handles.video, HI);
% preview(handles.video);
% set axes de captura
axes(handles.axesCaptura);
axis off;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes detector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = detector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.tablaResultado,'data', []);
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnCaptura.
function btnCaptura_Callback(hObject, eventdata, handles)
handles.my_img = getsnapshot(handles.video); %función de captura de una imagen
axes(handles.axesImagen);
imshow(uint8(handles.my_img));
img_name = "img_" + datestr(now,'yyyy-mm-dd_hh-MM-ss.jpg');
imwrite(handles.my_img, char(img_name));

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in btnArchivo.
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

% --- Executes on button press in btnProcesar.
function btnProcesar_Callback(hObject, eventdata, handles)

set(handles.tablaResultado,'data', []);

I =rgb2gray(handles.my_img);
[M,N,P] = size(I);

% umbralizar la imagen
I_sinfondo = zeros(M,N);
mask_1 = find(I >= 130); % detectar verdes
I_sinfondo(mask_1) = 255;

% I_sinfondo = ~I_sinfondo*255;
figure(1)
imshow(uint8(I_sinfondo));
impixelinfo;

% detectar objetos
len_card = M*N*0.10; % una carta ocupa aprox el 10% de la imagen
num_cards = 0;
[etiquetas, num_objetos] = bwlabel(I_sinfondo, 8);
fig_index = 2;
lista_cartas = {};

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
        lista_cartas(end+1).valor = numero_carta;
        
        % imprimir en la tabla los valores de las cartas
        data = get(handles.tablaResultado, 'data');
        data = [data ; [{numero_carta} {0}]];
        set(handles.tablaResultado,'data',data);
    end
end
