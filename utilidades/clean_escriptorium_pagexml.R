#' @title clean_escriptorium_pagexml
#' 
#' 
#' @description 
#' Este script automatiza la limpieza de archivos PAGE XML generados tras la segmentación 
#' en la plataforma eScriptorium. 
#' 
#' El proceso de segmentación automática a veces identifica erróneamente manchas, defectos 
#' del papel o elementos gráficos no textuales como si fueran regiones de texto (TextRegion) 
#' o líneas (TextLine). Esto resulta en etiquetas estructurales vacías que carecen de 
#' contenido real en la etiqueta <Unicode>.
#' 
#' @details 
#' El script realiza las siguientes acciones:
#' 1. Identifica y elimina nodos <TextLine> cuyo contenido <Unicode> esté vacío o solo 
#'    contenga espacios en blanco.
#' 2. Identifica y elimina nodos <TextRegion> que, tras la limpieza de líneas, no 
#'    contengan ninguna <TextLine> en su interior.
#' 3. Conserva estrictamente los Namespaces originales (xmlns) para asegurar la 
#'    compatibilidad con los esquemas de PAGE XML y eScriptorium.
#' 4. Excluye automáticamente el archivo 'METS.xml' para evitar la corrupción de 
#'    metadatos del proyecto.
#' 
#' @usage 
#' 1. Cargar las funciones ejecutando este script.
#' 2. Para procesar una carpeta completa (sobrescribiendo archivos):
#'    batch_clean_pages("ruta/a/mis/xmls")
#' 
#' @author José Manuel Fradejas Rueda
#' @organization Universidad de Valladolid
#' @date 2026-03-19

library(xml2)
library(purrr)

# --- FUNCIÓN 1: Limpieza profunda y sobrescritura ---
clean_page_xml <- function(file_path) {
  tryCatch({
    # Leer el documento original
    doc <- read_xml(file_path)
    ns <- xml_ns(doc)
    
    # 1. Eliminar TextLines cuyo Unicode esté vacío o solo tenga espacios
    all_lines <- xml_find_all(doc, ".//d1:TextLine", ns)
    lines_removed <- 0
    
    for (line in all_lines) {
      unicode_node <- xml_find_first(line, ".//d1:Unicode", ns)
      texto <- xml_text(unicode_node)
      
      # Si el nodo no existe o el texto está vacío tras limpiar espacios
      if (is.na(texto) || trimws(texto) == "") {
        xml_remove(line)
        lines_removed <- lines_removed + 1
      }
    }
    
    # 2. Eliminar TextRegions que no tengan ninguna TextLine (tras la limpieza anterior)
    text_regions <- xml_find_all(doc, ".//d1:TextRegion", ns)
    regions_removed <- 0
    
    for (tr in text_regions) {
      has_textline <- length(xml_find_all(tr, "./d1:TextLine", ns)) > 0
      
      if (!has_textline) {
        xml_remove(tr)
        regions_removed <- regions_removed + 1
      }
    }
    
    # 3. Sobrescribir el archivo original solo si hubo cambios
    total_changes <- lines_removed + regions_removed
    
    if (total_changes > 0) {
      write_xml(doc, file_path) # Sobrescritura directa
      message(paste0("✓ ", basename(file_path), ": ", 
                     lines_removed, " líneas y ", 
                     regions_removed, " regiones eliminadas."))
    } else {
      message(paste("·", basename(file_path), ": Sin cambios."))
    }
    
    return(total_changes)
    
  }, error = function(e) {
    message(paste("Error crítico en", file_path, ":", e$message))
    return(NA)
  })
}

# --- FUNCIÓN 2: Procesamiento por lotes (Sobrescritura total) ---
batch_clean_pages <- function(directory = ".") {
  # Listar XMLs excluyendo METS.xml
  files <- list.files(directory, pattern = "\\.xml$", full.names = TRUE)
  files <- files[!grepl("METS\\.xml$", files, ignore.case = TRUE)]
  
  if (length(files) == 0) {
    return(message("No se encontraron archivos XML en el directorio."))
  }
  
  cat("Iniciando limpieza y sobrescritura de archivos...\n")
  
  # Ejecutar la limpieza en cada archivo
  walk(files, clean_page_xml)
  
  cat("=== Proceso finalizado con éxito ===\n")
}


