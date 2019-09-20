
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% COPIA DE ETIQUETADO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extraccion de objetos etiquetados por el usuario de todos los
% ficheros de un directorio. Se usa la funcion "etiquetar" para ello. Se
% guarda en un fichero la estructura "Medidas", que contiene todas las
% medidas de cada objeto mas un campo "Label" que anyade la funcion
% "etiquetar", mas un campo "ImagenProcedencia" que anyadimos aqui.

clear all;
close all;

path = '/home/jahel/Documentos/Master/VisionPorComputador/Trabajo2D/img_poker_bmp';

path=uigetdir(path,'Directorio con las imagenes a etiquetar');
path=strcat(path,'/');
files = dir(strcat(path,'*.bmp'));

Medidas={};
i=1;
for file = files'
  pathname=strcat(path,file.name);
  if i == 1
      [F,objetos,abort] = etiquetar(pathname);
  else
      sizespalo = [size(F(1).Palo.ImageRGB,1) size(F(1).Palo.ImageRGB,2)];
      sizesnum = [size(F(1).Numero.ImageBW,1) size(F(1).Numero.ImageBW,2)];
      [F,objetos,abort] = etiquetar(pathname, sizespalo, sizesnum);
  end
  close all;
  Medidas{i,1} = F;
  Medidas{i,2} = file.name;
  i = i+1;
  if (abort)
    break;
  end
end
NumObjetos=i-2;
fprintf('Se han etiquetado %d objetos\n', NumObjetos);

if NumObjetos==0
  return
end
% Medidas(NumObjetos:end)=[];

[File_Medidas,Path_Medidas] =uiputfile(strcat(path,'Medidas.mat'));
if ~File_Medidas
  return
end
Pathname_Medidas=strcat(Path_Medidas,File_Medidas);
save(Pathname_Medidas,'Medidas');
