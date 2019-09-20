# Vision - ReconocedorCartasPoker
Reconocedor de cartas de poker por palo y número/letra con MATLAB y OpenCv.

La carpeta de imágenes img_poker_bmp se encuentra en https://drive.google.com/open?id=1wyNPsjsElPTrfJEsM_Mx9isCDp5NBBrm
La carpeta de imágenes img_poker_bmp_test se encuentra en https://drive.google.com/open?id=1FamvMBwQLBQnBikDPHHrVxN_hmdO_OJF

Para el reconocedor se emplea el arlgoritmo de distancia euclídea de bits respecto de una referencia.

## Estructura del proyecto
Se ha dividido el proyecto en dos partes. La primera, en la carpeta 1_Etiquetado y la segunda en 2_Clasificado.

En 1_Etiquetado se realiza la adquisición de dato para poder entrenar el sistema y que se tenga una referencia a la hora de reconocer las cartas. Esta carpeta consta del método principal, MainEtiquetar.m, que llama a etiquetar.m y a su vez, llama a segmentar.m, averagefilter.m y sauvola.m, siendo estos últimos compartidos por la parte de 2_Clasificado.

La siguiente fase, 2_Clasificado, contiene el método principal que es MainReconocimiento.m, que llama a extraer_caract_numero.m, extraer_caract_palo.m, EuclidDist.m y segmentar.m. Este último, al ser el mismo que en la anterior fase, también llama a averagefilter.m y sauvola.m.

## Fase de etiquetado

Esta fase no es más que una recogida de datos en una estructura, Medidas.mat, que contiene toda la información del etiquetado. En ella, se almacenan por cada fila los datos de cada imagen junto a su nombre. Dentro de los datos de cada imagen, se encuentran por filas las cartas detectadas por cada imagen, junto a su centroide, número detectado y palo. Dentro de número y palo están almacenadas las imágenes en si que son el número y el palo de tal modo que se sabe dónde está la carta en la imagen original y a qué carta pertenecen los números y palos identificados.

En esta fase lo más importante es el método segmentar.m, ya que en los demás solamente organizan en Medidas.mat los datos recogidos. Primero, hay un preproceso de la imagen para reducirla un cuarto, o el tratamiento de la imagen sería demasiado pesado. Se detecta el borde exterior de la carta a continuación, mediante sauvola y regionprops. La característica escogida para el filtrado ha sido el FilledArea, pues al final es lo más sencillo porque las cartas delimitan un área relativamente grande y cerrada con su perímetro.

Una vez seleccionada la carta, a través de la propiedad de la Orientation que dice la inclinación del eje mayor del perímetro detectado, se dispone la carta vertical, y se separa del resto para volver a extraer propiedades sobre la carta. En este caso, mediante el mismo procedimiento que antes (FilledArea), se detectan dos cosas. Primero, el cuadrado interno con región amarilla que tienen las cartas de Poker en su centro. Lo segundo, los iconos que hay en la carta, que en este caso son las figuras de dentro de la región amarilla y las del contorno de la carta.

Lo que se hace a continuación es solamente considerar los iconos (palo y número) que hay en la parte izquierda de la carta, entre el contorno exterior de la carta y el contorno interior, siendo el objeto de encima el número y el objeto de debajo el palo. Entonces, se asocian a Medidas.mat y se hace un recorte de la imagen que es el objeto, tanto el palo como el número.

En el caso del palo, se hace un recorte de la imagen en RGB, porque el palo va asociado al color y es un muy buen elemento distintivo para clasificar correctamente, pero en el caso del número, se ha aplicado una binarización sobre el recorte de la imagen, ya que lo que más importa es la forma del número, es decir, la disposición de los píxeles negros sobre blanco.

## Fase de clasificado
En esta fase se han empleado métodos distintos para reconocer el grupo del palo y el grupo del número. Para el palo, se ha empleado lo mismo que en clase, el algoritmo de Kvecinos fitcknn, ya que da buenos resultados y es muy sencillo de emplear.Con la carpeta de imágenes de training, identifica muy bien el palo. Solamente confunde picas con tréboles esporádicamente, pero es muy poco frecuente.

Mientras tanto, para reconocer el dígito es más complicado. Se ha empleado una técnica de distancia euclídea sobre una imagen binaria. Si tratamos a las imágenes como vectores, podemos saber el error que hay al comparar un vector (imagen) con alguna que ya esté etiquetada y por lo tanto, por similitud, se encontraría cuál es la clase para el vector imagen que queremos etiquetar en este instante. No se puede aplicar matriz de confusión en este caso para la distancia euclídea, porque siempre saldrá 0 al comprar la distancia euclídea de un vector consigo mismo.