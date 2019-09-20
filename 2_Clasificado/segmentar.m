% close all;
% clear all;
function salida=segmentar(ImagePathName, resizepalo, resizenum)
DEBUG = 0;
DEBUGCARTA = 0;
DEBUGICONO = 0;
% ImagePathName = '/home/jahel/Documentos/Master/VisionPorComputador/Trabajo2D/img_poker_bmp/img11.bmp';
I = imread(ImagePathName);

G=imresize(I,1/4);
Gbw = rgb2gray(G);
U=~sauvola(Gbw,[5 5]);
C=bwconncomp(U);
if DEBUGCARTA
    figure;
    L=labelmatrix(C);
    CL=label2rgb(L,@hsv,'w','shuffle');
    imshow(CL);
end

% Saber cual de las figuras es la mas pequenya para luego poder hacer
% resize y todas igual de grandes
minpalox = Inf;
minpaloy = Inf;
maxnumerox = 0;
maxnumeroy = 0;

% Areas para delimitar regiones
AreaCartaMax = 50000;
AreaCartaMin = 25000;
AreaContornoInteriorMin = 9000;
AreaContornoInteriorMax = 15000;
AreaIconoMax = 500;
AreaIconoMin = 50;

R = regionprops(C,'Orientation','BoundingBox','FilledArea','Centroid');
j=1;

scarta = struct('Carta',[], 'Centroid',[], 'ContornoExterior',[], 'ContornoInterior',[], 'Palo',[], 'Numero',[]);
Rtotal = [];

%% Separa las cartas para tratarlas por separado
for i = 1 : length(R)
    if (R(i).FilledArea < AreaCartaMax) && (R(i).FilledArea > AreaCartaMin)
        if DEBUGCARTA
            rectangle('Position',R(i).BoundingBox, 'LineWidth',2);
            text(R(i).BoundingBox(1)-10,R(i).BoundingBox(2)-10,int2str(R(i).Orientation));
        end
        % BoundingBox = left, top, width, height
        border = 35;
        aux = imcrop(G,[R(i).BoundingBox(1)-border,R(i).BoundingBox(2)-border,R(i).BoundingBox(3)+border*2,R(i).BoundingBox(4)+border*2]);
        if R(i).Orientation > 0
            Irot = imrotate(aux,(90-R(i).Orientation),'bilinear','crop');
        else
            Irot = imrotate(aux,(180+90-R(i).Orientation),'bilinear','crop');
        end
        scarta.Carta = Irot;
        scarta.Centroid = R(i).Centroid;
        Rtotal = [Rtotal; scarta];
        
    end
end

%% Trata cada carta por separado
for i = 1 : length(Rtotal)
    imgr = Rtotal(i).Carta;
    imgr_bw = rgb2gray(imgr);
    U=~sauvola(imgr_bw,[5 5]);
    C=bwconncomp(U);
    if DEBUG
        figure;
        L=labelmatrix(C);
        CL=label2rgb(L,@hsv,'w','shuffle');
        imshow(CL);
        pause(2);
    end
    % BoundingBox = left, top, width, height
    Rcarta = regionprops(C,'BoundingBox','FilledArea');
    
    %% Buscamos el contorno exterior e interior de la carta
    for j = 1 : length(Rcarta)
        % Buscamos el contorno exterior de carta 
        if (Rcarta(j).FilledArea < AreaCartaMax) && (Rcarta(j).FilledArea > AreaCartaMin)
            Rtotal(i).ContornoExterior = Rcarta(j);
        end
        % Buscamos el contorno interior de carta 
        if (Rcarta(j).FilledArea < AreaContornoInteriorMax) && (Rcarta(j).FilledArea > AreaContornoInteriorMin)
            Rtotal(i).ContornoInterior = Rcarta(j);
        end
    end
    
    leftexterior = ceil(Rtotal(i).ContornoExterior.BoundingBox(1));
    topexterior = ceil(Rtotal(i).ContornoExterior.BoundingBox(2));
    bottomexterior = topexterior + Rtotal(i).ContornoExterior.BoundingBox(4);
    leftinterior = ceil(Rtotal(i).ContornoInterior.BoundingBox(1));
    topinterior = ceil(Rtotal(i).ContornoInterior.BoundingBox(2));
    
    %% Buscamos el palo y numero
    for j = 1 : length(Rcarta)
        % Comprobamos que es un icono
        if (Rcarta(j).FilledArea < AreaIconoMax) && (Rcarta(j).FilledArea > AreaIconoMin)
            % Si la left del icono esta entre las lefts de los contornos y
            % si el top del icono esta entre el alto y bajo de la carta ext
            lefticono = ceil(Rcarta(j).BoundingBox(1));
            topicono = ceil(Rcarta(j).BoundingBox(2));
            if (lefticono > leftexterior) && (lefticono < leftinterior) && ...
               (topicono > topexterior) && (topicono < bottomexterior)
                % Si es el palo...
                if topicono >= topinterior
                    minpalox = min(minpalox, (Rcarta(j).BoundingBox(3)+1));
                    minpaloy = min(minpaloy, (Rcarta(j).BoundingBox(4)+1));
                    Rtotal(i).Palo = Rcarta(j);
                    if DEBUG
                        rectangle('Position',Rcarta(j).BoundingBox, 'LineWidth',2);
                        text(Rcarta(j).BoundingBox(1)-10,Rcarta(j).BoundingBox(2)-10,sprintf("Palo"));
                    end
        
                % Si es el numero...
                else
                    % Si no ocupa ninguna cifra previamente... (una cifra)
                    if size(Rtotal(i).Numero,1)==0
                        maxnumerox = max(maxnumerox, (Rcarta(j).BoundingBox(3)+1));
                        maxnumeroy = max(maxnumeroy, (Rcarta(j).BoundingBox(4)+1));
                        Rtotal(i).Numero = Rcarta(j);
                        if DEBUG
                            rectangle('Position',Rcarta(j).BoundingBox, 'LineWidth',2);
                            text(Rcarta(j).BoundingBox(1)-10,Rcarta(j).BoundingBox(2)-10,sprintf("Numero"));
                        end
                    else
                        maxnumerox = Rcarta(j).BoundingBox(3)+1;
                        maxnumeroy = Rcarta(j).BoundingBox(4)+1;
                        % Si ya habia un numero es porque es un 10. Lo
                        % fusionamos con la otra cifra
                        lefttotal = min(ceil(Rtotal(i).Numero.BoundingBox(1)),lefticono);
                        toptotal = min(ceil(Rtotal(i).Numero.BoundingBox(2)),topicono);
                        righttotal = max((ceil(Rtotal(i).Numero.BoundingBox(1))+Rtotal(i).Numero.BoundingBox(3)),...
                            (lefticono + Rcarta(j).BoundingBox(3)));
                        bottomtotal = max((ceil(Rtotal(i).Numero.BoundingBox(2))+Rtotal(i).Numero.BoundingBox(4)),...
                            (topicono + Rcarta(j).BoundingBox(4)));
                        Rtotal(i).Numero.BoundingBox = [lefttotal toptotal (righttotal - lefttotal) (bottomtotal - toptotal)];
                        Rtotal(i).Numero.FilledArea = 1;
                        if DEBUG
                            rectangle('Position',Rtotal(i).Numero.BoundingBox, 'LineWidth',2,'EdgeColor','r');
                            text(Rtotal(i).Numero.BoundingBox(1)-10,Rtotal(i).Numero.BoundingBox(2)-10,sprintf("Numero10"));
                        end
                    end
                end
            end
        end
    end
end

%% Una vez tenemos todo, recortamos las imagenes. Las de numero las ponemos 
% en B/W y las de palo, a color

for i = 1 : length(Rtotal)
   % Los palos
   Rtotal(i).Palo.ImageRGB = imcrop(Rtotal(i).Carta,Rtotal(i).Palo.BoundingBox);
   if nargin==1
       Rtotal(i).Palo.ImageRGB = imresize(Rtotal(i).Palo.ImageRGB,[minpaloy minpalox]);
   else
       Rtotal(i).Palo.ImageRGB = imresize(Rtotal(i).Palo.ImageRGB,[resizepalo(1) resizepalo(2)]);
   end
   if DEBUGICONO
       figure;
       imshow(Rtotal(i).Palo.ImageRGB);
       title(int2str(i) + " - Palo");
       pause(2);
   end
   % Los numeros
   numaux = imcrop(Rtotal(i).Carta,Rtotal(i).Numero.BoundingBox);
   numaux = rgb2gray(numaux);
   Rtotal(i).Numero.ImageBW = im2bw(numaux);   
   if nargin==1
       Rtotal(i).Numero.ImageBW = imresize(Rtotal(i).Numero.ImageBW,[maxnumeroy maxnumerox]);
   else
       Rtotal(i).Numero.ImageBW = imresize(Rtotal(i).Numero.ImageBW,[resizenum(1) resizenum(2)]);
   end
   if DEBUGICONO
       figure;
       imshow(Rtotal(i).Numero.ImageBW);
       title(int2str(i) + " - Numero");
       pause(2);
   end
end
salida = Rtotal;