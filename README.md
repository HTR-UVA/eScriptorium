# eScriptorium
Modelos y utilidades desarrallados para eScriptroium en la UVa

# Manual de eScriptorium
El manual para la instancia de eScriptorium de la UVa se encuentra en https://aic.uva.es/escriptorium/

# Modelos

Esta carpeta contiene los modelos que se desarrollen. Actualmente hay dos:

INC_HSMS
MSS_HSMS

`INC_HSMS_v1.mlmodel` está diseñado para la transcripción automática de incunables y libros impresos con letra gótica en castellano.

`MSS_HSMS_v1.mlmodel` está diseñado para la transcripción automática de manuscritos castellanos en una letra que se puede denominar ampliamente como gótica cursiva.

# Sistema de transcripción

Ambos modelos están diseñados para llevar a cabo transcripciones semipaleográficas de acuerdo con el sistema desarrollado por el Hispanic Seminary of Medieval Studies y que se explicita en este manual[https://www.hispanicseminary.org/manual-en.htm]. Ha de tenerse en cuenta que el sistema hace transcripción línea a línea, desarrolla las abreviaturas, que las marca con los signos ＜ ＞ o ⊂  (esto último es provisional). Las letras voladas, como se transcriben seguida del un acento grave ```: `q<u>i``. La abreviatura `v` se desarrolla sistem´ñaticamente como `v<er>` después cada transcriptor ha de procuparse de regularizar el uso —`v<er>` o `v<ir>`— dependiendo del uso del original.


# Utilidades

Este subdirectorio recoge todas aquellas utilidades, por lo general scripts en `R` o `Python` que se han desarrollado para el manejo y explotación de las transcripciones y ficheros que eScriptorium genere.

# Nota

En desarrollo
