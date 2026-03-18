# ============================================================
# renombrar_mets_page.R
# GIR Filología Digital
# Universidad de Valladolid
# Autor: José Manuel Fradejas Rueda + IA
# Marzo 2026
# ============================================================
#
# OBJETIVO
# --------
# Este script renombra de forma consistente un conjunto de ficheros
# descritos en un METS.xml y sus correspondientes PAGE.xml.
#
# El nuevo esquema de nombres es:
#
#     MSS_CUR_0001
#     MSS_CUR_0002
#     MSS_CUR_0003
#     ...
#
# conservando siempre la extensión original de cada fichero
# (.jpg, .xml, .tif, etc.).
#
#
# QUÉ HACE
# --------
# 1. Lee el fichero METS.xml.
# 2. Obtiene el orden correcto de lectura desde:
#
#       structMap TYPE="physical"
#
# 3. Para cada página, localiza:
#    - el fichero de imagen (fileGrp USE="image")
#    - el fichero PAGE.xml (fileGrp USE="export")
#
# 4. Genera nuevos nombres secuenciales con 4 dígitos:
#
#       MSS_CUR_0001
#       MSS_CUR_0002
#       ...
#
# 5. Actualiza en el METS.xml las referencias a los ficheros
#    (atributos xlink:href dentro de FLocat).
#
# 6. Actualiza en cada PAGE.xml el atributo:
#
#       <Page imageFilename="...">
#
#    para que apunte al nuevo nombre de la imagen.
#
# 7. Renombra físicamente en disco:
#    - las imágenes
#    - los PAGE.xml
#
# 8. Genera un CSV de control con las correspondencias entre
#    nombres antiguos y nombres nuevos.
#
# 9. Puede crear una copia de seguridad antes de modificar nada.
#
#
# QUÉ NO HACE
# -----------
# - No modifica los ID internos del METS.
# - No modifica otros identificadores internos del PAGE.xml.
# - Solo cambia:
#     a) los nombres físicos de los ficheros,
#     b) las referencias en METS.xml,
#     c) Page/@imageFilename en cada PAGE.xml.
#
#
# ESTRUCTURA ESPERADA
# ------------------
# El script supone que en la carpeta de trabajo están:
# - METS.xml
# - los ficheros de imagen
# - los ficheros PAGE.xml
#
# y que en el METS existen al menos:
# - fileGrp USE="image"
# - fileGrp USE="export"
# - structMap TYPE="physical"
#
#
# CONFIGURACIÓN PRINCIPAL
# -----------------------
# La configuración se encuentra en el objeto `config`.
#
# En particular, el fragmento del nombre que se quiere usar
# entre "MSS_" y el número secuencial se define aquí:
#
#     prefix = "MSS_CUR"
#
# Si se quiere cambiar "MSS_CUR_" por otro valor, hay que modificar
# ESTA LÍNEA.
#
# Ejemplos:
#
#     prefix = "MSS_CUR"
#     prefix = "MSS_GOT"
#     prefix = "MSS_ALB"
#     prefix = "INC_HSMS"
#     prefix = "INC_LAT"
#
# Si se cambia a:
#
#     prefix = "MSS_GOT"
#
# los nombres generados serán:
#
#     MSS_GOT_0001.jpg
#     MSS_GOT_0001.xml
#     MSS_GOT_0002.jpg
#     MSS_GOT_0002.xml
#
#
# MODO DE USO
# -----------
# 1. Colocar este script en la misma carpeta que METS.xml,
#    las imágenes y los PAGE.xml.
#
# 2. Abrir la carpeta o proyecto en RStudio.
#
# 3. Revisar en la configuración:
#    - base_dir
#    - mets_file
#    - prefix
#    - dry_run
#
# 4. Ejecutar primero en modo simulación:
#
#       dry_run = TRUE
#
#    Esto NO modifica ningún fichero; solo genera el plan.
#
# 5. Revisar el archivo:
#
#       rename_plan.csv
#
# 6. Si todo es correcto, cambiar a:
#
#       dry_run = FALSE
#
#    y volver a ejecutar el script.
#
#
# SALIDAS
# -------
# El script genera:
#
# - rename_plan.csv
#     Tabla con la correspondencia entre nombre antiguo y nombre nuevo.
#
# - _backup_rename/   (si make_backup = TRUE)
#     Copia de seguridad de los ficheros originales.
#
# - METS.xml actualizado
# - PAGE.xml actualizados
# - ficheros renombrados físicamente
#
#
# RECOMENDACIÓN
# -------------
# Ejecutar siempre primero con:
#
#     dry_run = TRUE
#
# y revisar el contenido de rename_plan.csv antes de aplicar
# cambios reales.
#
# ============================================================

suppressPackageStartupMessages({
  library(xml2)
  library(fs)
  library(readr)
  library(tibble)
  library(dplyr)
})

# ============================================================
# CONFIGURACIÓN
# ============================================================

config <- list(
  base_dir = ".",                  # carpeta de trabajo
  mets_file = "METS.xml",          # nombre del METS
  prefix = "MSS_CUR",              # prefijo nuevo
  digits = 4,                      # 0001 ... 9999
  dry_run = FALSE,                  # TRUE = simulación, no modifica nada
  make_backup = TRUE,              # crea copia de seguridad
  backup_dir = "_backup_rename",   # carpeta backup
  plan_csv = "rename_plan.csv",    # CSV con el plan
  overwrite_backup = FALSE         # no sobrescribir backup existente
)

# ============================================================
# UTILIDADES
# ============================================================

abort <- function(...) {
  stop(paste0(...), call. = FALSE)
}

msg <- function(...) {
  cat(paste0(..., "\n"))
}

make_new_base <- function(prefix, i, digits = 4) {
  sprintf("%s_%0*d", prefix, digits, i)
}

safe_copy <- function(from, to, overwrite = FALSE) {
  dir_create(path_dir(to), recurse = TRUE)
  
  if (!file_exists(from)) {
    abort("No existe el fichero origen para copiar: ", from)
  }
  
  if (file_exists(to) && !overwrite) {
    abort("Ya existe la copia de seguridad y overwrite_backup=FALSE: ", to)
  }
  
  file_copy(from, to, overwrite = overwrite)
  
  if (!file_exists(to)) {
    abort("No se pudo copiar: ", from, " -> ", to)
  }
}

safe_move <- function(from, to) {
  if (!file_exists(from)) {
    abort("No existe el fichero origen: ", from)
  }
  
  if (file_exists(to)) {
    abort("Ya existe el fichero destino: ", to)
  }
  
  dir_create(path_dir(to), recurse = TRUE)
  
  file_move(from, to)
  
  if (!file_exists(to)) {
    abort("No se pudo mover: ", from, " -> ", to)
  }
  
  if (file_exists(from)) {
    abort("El fichero origen sigue existiendo tras moverlo: ", from)
  }
}

get_extension <- function(x) {
  ext <- path_ext(x)
  if (is.na(ext) || ext == "") {
    abort("Fichero sin extensión: ", x)
  }
  ext
}

# Lectura robusta de FLocat/@xlink:href
get_xlink_href <- function(flocat_node) {
  attrs <- xml_attrs(flocat_node)
  
  if (length(attrs) < 1) {
    abort("FLocat no tiene atributos.")
  }
  
  nms <- names(attrs)
  idx <- grep("(^|:)href$|href$", nms)
  
  if (length(idx) < 1) {
    abort(
      "No se encontró ningún atributo href en FLocat. Atributos presentes: ",
      paste(nms, collapse = ", ")
    )
  }
  
  unname(attrs[[idx[1]]])
}

# Escritura robusta de FLocat/@xlink:href
set_xlink_href <- function(flocat_node, value) {
  attrs <- xml_attrs(flocat_node)
  nms <- names(attrs)
  idx <- grep("(^|:)href$|href$", nms)
  
  if (length(idx) >= 1) {
    xml_set_attr(flocat_node, nms[idx[1]], value)
  } else {
    xml_set_attr(flocat_node, "xlink:href", value)
  }
}

# Busca el nodo Page sin depender del namespace PAGE
find_page_node <- function(doc) {
  xml_find_first(doc, ".//*[local-name()='Page']")
}

# ============================================================
# RUTAS
# ============================================================

base_dir <- path_abs(config$base_dir)
mets_path <- path(base_dir, config$mets_file)
plan_csv_path <- path(base_dir, config$plan_csv)

if (!dir_exists(base_dir)) {
  abort("No existe la carpeta base: ", base_dir)
}
if (!file_exists(mets_path)) {
  abort("No existe el fichero METS: ", mets_path)
}

# ============================================================
# LEER METS
# ============================================================

msg("Leyendo METS: ", mets_path)

mets_doc <- read_xml(mets_path)

ns_mets <- c(
  mets  = "http://www.loc.gov/METS/",
  xlink = "http://www.w3.org/1999/xlink"
)

image_files <- xml_find_all(
  mets_doc,
  ".//mets:fileGrp[@USE='image']/mets:file",
  ns_mets
)

export_files <- xml_find_all(
  mets_doc,
  ".//mets:fileGrp[@USE='export']/mets:file",
  ns_mets
)

if (length(image_files) == 0) {
  abort("No se ha encontrado fileGrp USE='image' en el METS.")
}
if (length(export_files) == 0) {
  abort("No se ha encontrado fileGrp USE='export' en el METS.")
}

image_tbl <- tibble(
  fileid = xml_attr(image_files, "ID"),
  href = vapply(image_files, function(node) {
    flocat <- xml_find_first(node, "./mets:FLocat", ns_mets)
    if (inherits(flocat, "xml_missing")) {
      abort("Un <mets:file> de image no tiene <mets:FLocat>.")
    }
    get_xlink_href(flocat)
  }, FUN.VALUE = character(1))
)

export_tbl <- tibble(
  fileid = xml_attr(export_files, "ID"),
  href = vapply(export_files, function(node) {
    flocat <- xml_find_first(node, "./mets:FLocat", ns_mets)
    if (inherits(flocat, "xml_missing")) {
      abort("Un <mets:file> de export no tiene <mets:FLocat>.")
    }
    get_xlink_href(flocat)
  }, FUN.VALUE = character(1))
)

if (anyDuplicated(image_tbl$fileid)) {
  abort("Hay IDs duplicados en fileGrp USE='image'.")
}
if (anyDuplicated(export_tbl$fileid)) {
  abort("Hay IDs duplicados en fileGrp USE='export'.")
}

# ============================================================
# ORDEN DE LECTURA DESDE structMap
# ============================================================

pages <- xml_find_all(
  mets_doc,
  ".//mets:structMap[@TYPE='physical']/mets:div[@TYPE='document']/mets:div[@TYPE='page']",
  ns_mets
)

if (length(pages) == 0) {
  abort("No se han encontrado páginas en structMap TYPE='physical'.")
}
if (length(pages) > 9999) {
  abort("Hay ", length(pages), " páginas; el formato de 4 dígitos no alcanza.")
}

msg("Páginas detectadas: ", length(pages))

# ============================================================
# CONSTRUIR PLAN
# ============================================================

plan_list <- vector("list", length(pages))

for (i in seq_along(pages)) {
  fptrs <- xml_find_all(pages[[i]], "./mets:fptr", ns_mets)
  fileids <- xml_attr(fptrs, "FILEID")
  
  img_ids <- intersect(fileids, image_tbl$fileid)
  xml_ids <- intersect(fileids, export_tbl$fileid)
  
  if (length(img_ids) != 1) {
    abort("La página ", i, " no tiene exactamente un FILEID de imagen.")
  }
  if (length(xml_ids) != 1) {
    abort("La página ", i, " no tiene exactamente un FILEID de export/PAGE.xml.")
  }
  
  old_img_rel <- image_tbl$href[match(img_ids, image_tbl$fileid)]
  old_xml_rel <- export_tbl$href[match(xml_ids, export_tbl$fileid)]
  
  img_ext <- get_extension(old_img_rel)
  xml_ext <- get_extension(old_xml_rel)
  
  new_base <- make_new_base(config$prefix, i, config$digits)
  
  plan_list[[i]] <- tibble(
    seq_num = i,
    img_fileid = img_ids,
    xml_fileid = xml_ids,
    old_img_rel = old_img_rel,
    old_xml_rel = old_xml_rel,
    new_base = new_base,
    new_img_rel = paste0(new_base, ".", img_ext),
    new_xml_rel = paste0(new_base, ".", xml_ext)
  )
}

plan <- bind_rows(plan_list) %>%
  mutate(
    old_img_abs = path(base_dir, old_img_rel),
    old_xml_abs = path(base_dir, old_xml_rel),
    new_img_abs = path(base_dir, new_img_rel),
    new_xml_abs = path(base_dir, new_xml_rel)
  )

# ============================================================
# VALIDACIONES PREVIAS
# ============================================================

if (anyDuplicated(plan$new_img_rel)) {
  abort("Se han generado nombres nuevos de imagen duplicados.")
}
if (anyDuplicated(plan$new_xml_rel)) {
  abort("Se han generado nombres nuevos de PAGE.xml duplicados.")
}

missing_img <- plan$old_img_abs[!file_exists(plan$old_img_abs)]
missing_xml <- plan$old_xml_abs[!file_exists(plan$old_xml_abs)]

if (length(missing_img) > 0 || length(missing_xml) > 0) {
  abort(
    "Faltan ficheros físicos referenciados por el METS:\n",
    paste(c(missing_img, missing_xml), collapse = "\n")
  )
}

img_collision <- file_exists(plan$new_img_abs) &
  (path_norm(plan$new_img_abs) != path_norm(plan$old_img_abs))

xml_collision <- file_exists(plan$new_xml_abs) &
  (path_norm(plan$new_xml_abs) != path_norm(plan$old_xml_abs))

if (any(img_collision)) {
  abort(
    "Ya existen ficheros destino de imagen:\n",
    paste(plan$new_img_abs[img_collision], collapse = "\n")
  )
}
if (any(xml_collision)) {
  abort(
    "Ya existen ficheros destino de PAGE.xml:\n",
    paste(plan$new_xml_abs[xml_collision], collapse = "\n")
  )
}

# ============================================================
# VALIDAR PAGE.XML Y LEER imageFilename
# ============================================================

msg("Validando PAGE.xml...")

page_check <- lapply(seq_len(nrow(plan)), function(i) {
  page_doc <- read_xml(plan$old_xml_abs[i])
  page_node <- find_page_node(page_doc)
  
  if (inherits(page_node, "xml_missing")) {
    abort("No se encontró el elemento <Page> en: ", plan$old_xml_abs[i])
  }
  
  image_filename <- xml_attr(page_node, "imageFilename")
  
  if (is.na(image_filename) || image_filename == "") {
    abort("Falta el atributo @imageFilename en: ", plan$old_xml_abs[i])
  }
  
  tibble(
    seq_num = plan$seq_num[i],
    page_imageFilename = image_filename
  )
})

page_check <- bind_rows(page_check)
plan <- left_join(plan, page_check, by = "seq_num")

# ============================================================
# GUARDAR CSV DEL PLAN
# ============================================================

plan_export <- plan %>%
  select(
    seq_num,
    img_fileid,
    xml_fileid,
    old_img_rel,
    old_xml_rel,
    page_imageFilename,
    new_base,
    new_img_rel,
    new_xml_rel
  )

write_csv(plan_export, plan_csv_path)
msg("Plan guardado en: ", plan_csv_path)

msg("")
msg("Resumen del plan:")
for (i in seq_len(nrow(plan_export))) {
  msg(sprintf(
    "  %04d | IMG %s -> %s | XML %s -> %s",
    plan_export$seq_num[i],
    plan_export$old_img_rel[i], plan_export$new_img_rel[i],
    plan_export$old_xml_rel[i], plan_export$new_xml_rel[i]
  ))
}
msg("")

if (isTRUE(config$dry_run)) {
  msg("DRY RUN activado: no se ha modificado ningún archivo.")
} else {
  
  # ==========================================================
  # COPIA DE SEGURIDAD
  # ==========================================================
  
  if (isTRUE(config$make_backup)) {
    backup_root <- path(base_dir, config$backup_dir)
    dir_create(backup_root, recurse = TRUE)
    
    msg("Creando copia de seguridad en: ", backup_root)
    
    safe_copy(
      mets_path,
      path(backup_root, path_file(config$mets_file)),
      overwrite = config$overwrite_backup
    )
    
    safe_copy(
      plan_csv_path,
      path(backup_root, path_file(config$plan_csv)),
      overwrite = config$overwrite_backup
    )
    
    for (i in seq_len(nrow(plan))) {
      safe_copy(
        plan$old_img_abs[i],
        path(backup_root, plan$old_img_rel[i]),
        overwrite = config$overwrite_backup
      )
      safe_copy(
        plan$old_xml_abs[i],
        path(backup_root, plan$old_xml_rel[i]),
        overwrite = config$overwrite_backup
      )
    }
  }
  
  # ==========================================================
  # ACTUALIZAR PAGE.XML
  # ==========================================================
  
  msg("Actualizando PAGE.xml...")
  
  for (i in seq_len(nrow(plan))) {
    page_doc <- read_xml(plan$old_xml_abs[i])
    page_node <- find_page_node(page_doc)
    
    if (inherits(page_node, "xml_missing")) {
      abort("No se encontró <Page> en: ", plan$old_xml_abs[i])
    }
    
    xml_set_attr(page_node, "imageFilename", plan$new_img_rel[i])
    
    write_xml(page_doc, file = plan$old_xml_abs[i], options = "format")
  }
  
  # ==========================================================
  # ACTUALIZAR METS.XML
  # ==========================================================
  
  msg("Actualizando METS.xml...")
  
  for (i in seq_len(nrow(plan))) {
    img_flocat <- xml_find_first(
      mets_doc,
      sprintf(".//mets:file[@ID='%s']/mets:FLocat", plan$img_fileid[i]),
      ns_mets
    )
    if (inherits(img_flocat, "xml_missing")) {
      abort("No se encontró FLocat para el FILEID de imagen: ", plan$img_fileid[i])
    }
    set_xlink_href(img_flocat, plan$new_img_rel[i])
    
    xml_flocat <- xml_find_first(
      mets_doc,
      sprintf(".//mets:file[@ID='%s']/mets:FLocat", plan$xml_fileid[i]),
      ns_mets
    )
    if (inherits(xml_flocat, "xml_missing")) {
      abort("No se encontró FLocat para el FILEID de export: ", plan$xml_fileid[i])
    }
    set_xlink_href(xml_flocat, plan$new_xml_rel[i])
  }
  
  write_xml(mets_doc, file = mets_path, options = "format")
  
  # ==========================================================
  # RENOMBRADO FÍSICO EN DOS FASES
  # ==========================================================
  
  msg("Renombrando ficheros físicos...")
  
  tmp_suffix <- ".__tmp_rename__"
  
  for (i in seq_len(nrow(plan))) {
    safe_move(plan$old_img_abs[i], paste0(plan$new_img_abs[i], tmp_suffix))
    safe_move(plan$old_xml_abs[i], paste0(plan$new_xml_abs[i], tmp_suffix))
  }
  
  for (i in seq_len(nrow(plan))) {
    safe_move(paste0(plan$new_img_abs[i], tmp_suffix), plan$new_img_abs[i])
    safe_move(paste0(plan$new_xml_abs[i], tmp_suffix), plan$new_xml_abs[i])
  }
  
  msg("")
  msg("Proceso completado correctamente.")
  msg("METS actualizado: ", mets_path)
  msg("CSV de trazabilidad: ", plan_csv_path)
  if (isTRUE(config$make_backup)) {
    msg("Copia de seguridad: ", path(base_dir, config$backup_dir))
  }
}