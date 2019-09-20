function PrediccionesNum=EuclidDist(imgNumBW, imgNumBWtest, etiqNum)
for i = 1:size(imgNumBWtest,1)
    gradienteAct = Inf;
    gradientePrev = gradienteAct;
    cont_mas_parecido = 0;
    % Hago distancia euclidea con datos de training a ver a cual se parece
    % mas (menos distancia, mas parecido)
    for j = 1:size(imgNumBW,1)
        gradienteAct = sqrt(sum((imgNumBW(j,:) - imgNumBWtest(i,:)) .^ 2));
        if gradienteAct < gradientePrev
            gradientePrev = gradienteAct;
            cont_mas_parecido = j;
        end
    end
    PrediccionesNum{i,1} = etiqNum{1,cont_mas_parecido};
end

