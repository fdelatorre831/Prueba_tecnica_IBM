# Prueba Técnica — Procesamiento Batch y Consultas

## Descripción general

Este repositorio contiene la resolución de una prueba técnica que abarca distintos perfiles técnicos, incluyendo:

* Consultas SQL con reglas de negocio explícitas
* Un programa batch en COBOL que procesa múltiples archivos secuenciales
* Documentación funcional de un sistema externo («n8n»)

El objetivo principal del trabajo es demostrar capacidad de análisis, toma de decisiones ante ambigüedades, validación estricta de datos y explicación clara de las soluciones implementadas.

---

## Estructura del repositorio

El repositorio está organizado en una única carpeta que contiene todos los entregables de la prueba:

/
├── IBM_Cobol.cob
├── Prueba técnica IBM Consultas SQL.sql
├── Ejercicio 3 n8n documentacion.docx
└── README.md

### Descripción de los archivos

* **IBM_Cobol.cob**
  Programa batch desarrollado en COBOL. Procesa los archivos de entrada, aplica validaciones estrictas y genera un reporte por idioma.

* **Prueba técnica IBM Consultas SQL.sql**
  Archivo con las consultas SQL correspondientes a los ejercicios de base de datos. Incluye subconsultas, filtros complejos y criterios de ordenamiento justificados.

* **Ejercicio 3 n8n documentacion.docx**
  Documento Word con la documentación funcional del sistema «n8n», orientada a usuarios funcionales y técnicos. No es una traducción ni un resumen del README oficial del proyecto.

* **README.md**
  Documento actual. Describe la estructura del repositorio y la forma de ejecutar o interpretar cada entrega.

---

## Ejecución del programa COBOL

### Requisitos

* Compilador COBOL (por ejemplo, GnuCOBOL)
* Entorno de ejecución batch
* Archivos de entrada:

  * palabras.dat
  * idiomas.dat

### Formato de los archivos de entrada

idiomas.dat <idioma>|<descripcion>

palabras.dat <codigo>|<palabra>|<idioma>

### Compilación

Ejemplo utilizando GnuCOBOL:

cobc -x IBM_Cobol.cob

### Ejecución

El programa recibe como parámetro una letra alfabética entre «A» y «Z»:

./IBM_Cobol A

La letra puede pasarse en minúscula; el programa la normaliza internamente.

### Salida

* El reporte se muestra por salida estándar (SYSOUT).
* Ante el primer error de validación:

  * Se muestra un mensaje descriptivo
  * Se indica la línea procesada
  * El programa finaliza inmediatamente

---

## Consideraciones de diseño

* Todas las validaciones solicitadas en el enunciado son estrictas.
* No se continúa el procesamiento luego de un error fatal.
* El promedio de longitud de palabras se calcula sin divisiones en línea, acumulando valores y dividiendo únicamente al final.
* Las decisiones tomadas ante ambigüedades están justificadas en la resolución conceptual de la prueba.

---

## Notas finales

Este repositorio no está pensado como un proyecto productivo completo, sino como una demostración de criterios técnicos, capacidad de análisis y claridad explicativa, tal como se solicita en la prueba técnica.
