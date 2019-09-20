% Devuelve las caracteristicas que se extraen usando la funcion "segmentar"
% de la imagen en el fichero ImagePathName con un campo adicional llamado
% "label" para cada objeto segmentado. Las etiquetas se le solicitan al
% usuario mediante un cuadro de dialogo.
function [etiquetas,objetos,abort]=etiquetar(ImagePathName, resizepalo, resizenum)
  
  I = imread(ImagePathName);
  G=imresize(I,1/4);
  
  if nargin==1
    F = segmentar(ImagePathName);
  else
    F = segmentar(ImagePathName, resizepalo, resizenum);
  end
  abort=0;
  n=length(F);
  i=0;
  while i < n
    i=i+1;
    close;
    RGB = insertMarker(G,F(i).Centroid,'*','size',10);
    imshow(RGB);
    pause(1);
    
    % Palo
    figure;
    imshow(F(i).Palo.ImageRGB);
    labelspalo = {'Pica','Diamante','Trebol','Corazon'};
    accion='Seguir';
    
    msg=sprintf('Etiquetar objeto %d de imagen %s',i,ImagePathName);
    [etiq,ok] = listdlg('PromptString',msg,...
      'SelectionMode','single',...
      'ListString',labelspalo);
    if (ok==0)
      accion=questdlg('Quieres detener el proceso?', ...
        'Control del etiquetado', ...
        'Seguir','Volver al objeto anterior','Acabar','Seguir');
      
      switch accion
        case 'Seguir'
          if i>0
            i=i-1;
            continue
          end
        case 'Volver al objeto anterior'
          if i>1
            i=i-2;
            continue
          end
        otherwise
          break
      end
    end
    F(i).Palo.Label=labelspalo{etiq};
    fprintf('La etiqueta es:  %s\n', labelspalo{etiq});
    close;
    
    % Image
    figure;
    imshow(F(i).Numero.ImageBW);
    labelsnum = {'A','2','3','4','5','6','7','8','9','10','J','Q','K'};
    accion='Seguir';
    
    msg=sprintf('Etiquetar objeto %d de imagen %s',i,ImagePathName);
    [etiq,ok] = listdlg('PromptString',msg,...
      'SelectionMode','single',...
      'ListString',labelsnum);
    if (ok==0)
      accion=questdlg('Quieres detener el proceso?', ...
        'Control del etiquetado', ...
        'Seguir','Volver al objeto anterior','Acabar','Seguir');
      
      switch accion
        case 'Seguir'
          if i>0
            i=i-1;
            continue
          end
        case 'Volver al objeto anterior'
          if i>1
            i=i-2;
            continue
          end
        otherwise
          break
      end
    end
    F(i).Numero.Label=labelsnum{etiq};
    fprintf('La etiqueta es:  %s\n', labelsnum{etiq});
    close;
  end
  etiquetas=F;
  objetos=i;
  if strcmp(accion,'Acabar')
    abort=1;
    return
  end
end
