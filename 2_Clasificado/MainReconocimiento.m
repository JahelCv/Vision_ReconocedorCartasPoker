% Evaluacion de un clasificador sobre unas estructuras de caracteristicas
% obtenidas con extraer_caract a partir de un conjunto de Medidas generadas
% por VxC_Etiquetado.
close all;
clear all;

PathTrain = '/home/jahel/Documentos/Master/VisionPorComputador/Trabajo2D/img_poker_bmp/';
PathTest = '/home/jahel/Documentos/Master/VisionPorComputador/Trabajo2D/img_poker_bmp_test/';

[File_Medidas,Path_Medidas] =uigetfile(strcat(PathTrain,'Medidas.mat'),'Fichero de Medidas y etiquetas');
Pathname_Medidas=strcat(Path_Medidas,File_Medidas);
load(Pathname_Medidas);

Path_Test=uigetdir(PathTest,'Directorio con las imagenes a reconocer');
Path_Test=strcat(Path_Test,'/');
files = dir(strcat(Path_Test,'*.bmp'));

%% Caracterizo training 
[imgPaloRGB, etiqPalo, ~, medidasresizePalo] = extraer_caract_palo(Medidas);
[imgNumBW, etiqNum, centroidecarta, medidasresizeNum] = extraer_caract_numero(Medidas);

%% Caracterizo test
MedidasTest={};
i=1;
% Tomo medidas de palo y num para homogeneizar las imagenes
resizepalotest = [size(Medidas{1,1}(1).Palo.ImageRGB,1) size(Medidas{1,1}(1).Palo.ImageRGB,2)];
resizenumtest = [size(Medidas{1,1}(1).Numero.ImageBW,1) size(Medidas{1,1}(1).Numero.ImageBW,2)];
for file = files'
  pathname=strcat(Path_Test,file.name);
  F = segmentar(pathname,resizepalotest,resizenumtest);
  MedidasTest{i,1} = F;
  MedidasTest{i,2} = file.name;
  for j=1 : length(F)
    MedidasTest{i,1}(j).Palo.Label='?';
    MedidasTest{i,1}(j).Numero.Label='?';
  end
  i=i+1;
  fprintf('Imagen %s procesada. Se han hallado en ella %d objetos\n', file.name, j);
end

% Obtengo caracteristicas del test
[imgPaloRGBtest, etiqPalotest, ~, ~] = extraer_caract_palo(MedidasTest,medidasresizePalo);
[imgNumBWtest, etiqNumtest, centroidecartatest, ~] = extraer_caract_numero(MedidasTest,medidasresizeNum);

%% Clasificacion del palo con fitcknn
ClasificadorPalo=fitcknn(imgPaloRGB,etiqPalo');
ClasificadorPalo.NumNeighbors = 3;

% Evaluacion del palo
ValidacionCruzadaPalo=crossval(ClasificadorPalo,'kfold',10);
Error = kfoldLoss(ValidacionCruzadaPalo);
PrediccionesPaloConfMatrix = predict(ClasificadorPalo,imgPaloRGB);

%% Clasificacion del numero mediante distancia euclidea
PrediccionesNumConfMatrix = EuclidDist(imgNumBW, imgNumBW, etiqNum);
PrediccionesNum = EuclidDist(imgNumBW, imgNumBWtest, etiqNum);

%% Test
PrediccionesPalo = predict(ClasificadorPalo,imgPaloRGBtest);

if length(PrediccionesPalo) == length(PrediccionesNum)
    Iactual='';
    for i = 1 : length(PrediccionesPalo)
      if ~strcmp(Iactual,centroidecartatest{i,1})
        if ~strcmp(Iactual,'')
          seguir = questdlg('Resultados','Siguiente imagen', 'OK', 'Salir', 'OK');
          if strcmp(seguir,'Salir')
            break;
          end
        end
        close;
        Iactual=centroidecartatest{i,1};
        G = imread(strcat(Path_Test,Iactual));
        I=imresize(G,1/4);
        imshow(I);
      end
      I = insertMarker(I,centroidecartatest{i,2},'*','size',10);
      texto = strcat(PrediccionesPalo(i)," - ",PrediccionesNum(i));
      text(centroidecartatest{i,2}(1),centroidecartatest{i,2}(2)-20,texto,...
        'FontSize',14,'BackgroundColor','white','Margin',0.01,'VerticalAlignment','top');
    end
else
    fprintf("ERROR! No se ha detectado el mismo numero de numeros que de palos");
end

%% Evaluacion del error

[MatrizConfPalo,OrdenClasesPalo] = confusionmat(PrediccionesPaloConfMatrix,etiqPalo');
disp("Matriz de confusion del palo");
disp(OrdenClasesPalo');
disp(MatrizConfPalo);

[MatrizConfNum,OrdenClasesNum] = confusionmat(PrediccionesNumConfMatrix,etiqNum');
disp("Matriz de confusion del numero");
disp(OrdenClasesNum');
disp(MatrizConfNum);
