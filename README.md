# eScriptorium - UVa

Modelos y utilidades desarrollados para la instancia de **eScriptorium** en la Universidad de Valladolid (UVa).

## 📖 Manual de Uso
El manual detallado para nuestra instancia se puede consultar en el siguiente enlace:
👉 [Manual eScriptorium UVa](https://aic.uva.es/escriptorium/)

---

## 🤖 Modelos Disponibles
Esta sección contiene los modelos de transcripción automática (HTR) desarrollados. Actualmente contamos con:

### 1. INC_HSMS (`INC_HSMS_v1.mlmodel`)
* **Propósito:** Transcripción de **incunables y libros impresos**.
* **Tipografía:** Letra gótica en castellano.

### 2. MSS_HSMS (`MSS_HSMS_v1.mlmodel`)
* **Propósito:** Transcripción de **manuscritos castellanos**.
* **Tipografía:** Gótica cursiva (denominación amplia).

Han de citarse:

Fradejas Rueda, J. J. & Cardeñoso, V. (2025), INC_HSMS_v1.mlmodel, Universidad de Valladolid
Fradejas Rueda, J. J. & Cardeñoso, V. (2025), MSS_HSMS_v1.mlmodel, Universidad de Valladolid

---

## ✍️ Sistema de Transcripción
Ambos modelos siguen un criterio de **transcripción semipaleográfica** basado en el sistema del *Hispanic Seminary of Medieval Studies* ([Manual de normas HSMS](https://www.hispanicseminary.org/manual-en.htm)).

### Particularidades del sistema:
* **Línea a línea:** La transcripción respeta la disposición original del texto.
* **Abreviaturas:** Se desarrollan utilizando los signos `＜ ＞` o `⊂ ⊃` (este último par es de carácter provisional).
    * Ejemplo: La abreviatura `v͑` se desarrolla sistemáticamente como `v<er>`. El transcriptor deberá regularizar posteriormente a `v<er>` o `v<ir>` según el contexto y el uso de su original.
* **Letras voladas:** Se transcriben seguidas de un acento grave.
    * Ejemplo: `q<u>i` para representar la abreviatura de *qui*.

---

## ⌨️ Teclados

Esta sección contiene los diversos teclados que, de acuerdo con el sistema de codificación del HSMS se han ido desarrollando

---

## 🛠️ Utilidades
En el subdirectorio `/utilidades` se encuentran scripts en **R** y **Python** diseñados para:
* Manejo y limpieza de datos.
* Explotación de ficheros generados por eScriptorium.
* Conversión de formatos.

---

## ⚠️ Nota
> [!IMPORTANT]
> Este repositorio se encuentra actualmente **en desarrollo**. Las herramientas y modelos pueden sufrir actualizaciones frecuentes.

---

---

## ⚖️ Licencia

Este proyecto y los modelos contenidos en él están bajo una licencia **[Creative Commons Atribución 4.0 Internacional (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/deed.es)**.

### Cómo citar este trabajo
Si utilizas estos modelos o utilidades en tu investigación, por favor cita este repositorio de la siguiente manera:

> *Modelos y utilidades para eScriptorium en la UVa (2026). Desarrollado por el GIR Filología Digital. Universidad de Valladolid.*

---


---
