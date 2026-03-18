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

---

## ✍️ Sistema de Transcripción
Ambos modelos siguen un criterio de **transcripción semipaleográfica** basado en el sistema del *Hispanic Seminary of Medieval Studies* ([Manual de normas HSMS](https://www.hispanicseminary.org/manual-en.htm)).

### Particularidades del sistema:
* **Línea a línea:** La transcripción respeta la disposición original del texto.
* **Abreviaturas:** Se desarrollan utilizando los signos `＜ ＞` o `⊂` (este último de carácter provisional).
    * Ejemplo: La abreviatura `v` se desarrolla sistemáticamente como `v<er>`. El transcriptor deberá regularizar posteriormente a `v<er>` o `v<ir>` según el contexto.
* **Letras voladas:** Se transcriben seguidas de un acento grave.
    * Ejemplo: `q<u>i` para representar la abreviatura de *qui*.

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
