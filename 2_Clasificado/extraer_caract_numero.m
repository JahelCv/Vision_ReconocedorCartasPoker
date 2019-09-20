% Extraccion de caracteristicas a partir de una estructura Medidas.mat
function [VectorImagenesBW, VectorEtiquetas, VectorPathNameCentroid, TamXY_BW]=...
    extraer_caract_numero(Medidas, medidasresize)

% Por cada fila es una imagen (imgX.bmp) y por cada imagen hay varios objetos a reconocer.
% Son una carta por fila, y por cada carta un palo y un numero.

% Por cada imagen
TamXY_BW = [];
contobjetos = 1;
for i= 1 : length(Medidas)
    % Por cada carta o palo
    for j = 1 : length(Medidas{i,1})
        VectorPathNameCentroid{contobjetos,1} = Medidas{i,2};
        VectorPathNameCentroid{contobjetos,2} = Medidas{i,1}(j).Centroid;
        % Me guardo lo que mide la imagen RGB
        imgaux = Medidas{i,1}(j).Numero.ImageBW;
        if nargin>1
            imgaux = imresize(imgaux,[medidasresize(1) medidasresize(2)]);
        elseif nargin == 1
            TamXY_BW(1) = size(imgaux,1);
            TamXY_BW(2) = size(imgaux,2);
        end
        % Pongo toda la imagen en una fila
        imgaux = reshape(imgaux,1,[]);
        VectorImagenesBW(contobjetos,1:size(imgaux,2)) = imgaux;
        % Coincide cada fila (imagen) con su etiqueta
        VectorEtiquetas{contobjetos} = Medidas{i,1}(j).Numero.Label;
        contobjetos = contobjetos + 1;
    end
end