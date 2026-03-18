# renombrar_mets_page.R

Script de procesamiento para la gestión de archivos XML y digitalizaciones del **GIR Filología Digital** de la **Universidad de Valladolid**.

* **Autor:** José Manuel Fradejas Rueda + IA
* **Fecha:** Marzo 2026
* **Versión:** 1.0

---

## 🎯 Objetivo
El propósito de este script es renombrar de forma consistente un conjunto de ficheros descritos en un `METS.xml`, sus correspondientes archivos `PAGE.xml` y las imágenes descargadas desde **eScriptorium**.

El esquema de nombres resultante sigue el patrón:
`MSS_CUR_0001`, `MSS_CUR_0002`, `MSS_CUR_0003`, etc., conservando siempre la extensión original (`.jpg`, `.xml`, `.tif`, etc.).

---

## 💻 Requisitos y Dependencias

Para ejecutar este script, necesitas tener instalado **R** (versión 4.0 o superior) y **RStudio**. Además, el script utiliza las siguientes librerías de R:

* **`xml2`**: Para la lectura y manipulación de los archivos XML (METS y PAGE).
* **`dplyr`**: Para la manipulación de datos y creación del plan de renombrado.
* **`stringr`**: Para el manejo de cadenas de texto y prefijos.

### Instalación de dependencias
Puedes instalar todas las librerías necesarias ejecutando este comando en tu consola de R:

```r
install.packages(c("xml2", "dplyr", "stringr"))
```

---

## 🛠️ Funcionalidades

### ¿Qué hace el script?
1.  **Lectura del METS:** Analiza el archivo `METS.xml` para determinar el orden correcto de lectura mediante el `structMap TYPE="physical"`.
2.  **Localización de archivos:** Identifica para cada página el fichero de imagen (`fileGrp USE="image"`) y el archivo de transcripción (`fileGrp USE="export"`).
3.  **Generación de nombres:** Crea una secuencia de 4 dígitos (ej. `0001`).
4.  **Actualización de metadatos:**
    * Modifica las referencias `xlink:href` dentro del `METS.xml`.
    * Actualiza el atributo `imageFilename` en los `PAGE.xml` para que coincidan con el nuevo nombre de imagen.
5.  **Ejecución física:** Renombra los archivos en el disco duro.
6.  **Control:** Genera un archivo **CSV de correspondencias** entre nombres antiguos y nuevos.
7.  **Seguridad:** Permite realizar una copia de seguridad antes de aplicar cambios.

### ¿Qué NO hace?
* No modifica los IDs internos del METS.
* No altera otros identificadores internos del PAGE.xml que no sean el nombre de la imagen.

---

## ⚙️ Configuración Principal
La configuración se define en el objeto `config`. El prefijo del nombre es el parámetro más importante:

```r
prefix = "MSS_CUR" # Cambiar por MSS_GOT, MSS_ALB, INC_LAT, etc.
```

| Prefijo ejemplo | Nombre resultante |
| :--- | :--- |
| `MSS_GOT` | `MSS_GOT_0001.jpg` |
| `INC_HSMS` | `INC_HSMS_0001.xml` |

---

## 🚀 Modo de Uso

1.  **Preparación:** Coloca el script en la misma carpeta que los archivos XML e imágenes.
2.  **Apertura:** Abre el script o el proyecto en **RStudio**.
3.  **Configuración:** Revisa las variables `base_dir`, `mets_file`, `prefix` y `dry_run`.
4.  **Simulación (Recomendado):**
    * Asegúrate de que `dry_run = TRUE`.
    * Ejecuta el script. Esto generará el archivo `rename_plan.csv` sin modificar nada.
5.  **Revisión:** Abre `rename_plan.csv` y verifica que el plan de renombrado es correcto.
6.  **Ejecución final:**
    * Cambia a `dry_run = FALSE`.
    * Vuelve a ejecutar el script para aplicar los cambios físicos.

---

## 📦 Salidas del Script
* **`rename_plan.csv`**: Tabla de trazabilidad antiguo ↔ nuevo.
* **`_backup_rename/`**: Carpeta con copias de seguridad (si `make_backup = TRUE`).
* **Archivos actualizados**: `METS.xml` y `PAGE.xml` modificados.
* **Ficheros renombrados**: Imágenes y XML con la nueva nomenclatura.

> [!IMPORTANT]
> **RECOMENDACIÓN:** Ejecutar siempre primero con `dry_run = TRUE` para evitar errores accidentales en la estructura de nombres.

---

¿Necesitas que incluya alguna instrucción específica sobre cómo gestionar los errores si faltan archivos?