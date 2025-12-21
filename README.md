# Prueba Técnica IBM

**Nombre:** Francisco de la Torre  
**Email:** fran.delatorre01@gmail.com  

---

## Introducción

Este repositorio contiene la resolución de la prueba técnica propuesta por IBM.

La prueba evalúa distintos perfiles técnicos y pone el foco en:

- Capacidad de análisis ante consignas ambiguas o incompletas  
- Validación estricta de datos  
- Justificación explícita de decisiones técnicas  
- Claridad en la documentación y en la estructura del repositorio  

La solución presentada no busca ser un producto final, sino una **demostración de criterio técnico, razonamiento y buenas prácticas**, siguiendo el espíritu del enunciado.

---

## Alcance de la entrega

En este repositorio se incluyen resoluciones correspondientes a los siguientes perfiles:

- SQL  
- Automatización / Documentación funcional  
- COBOL  

Cada ejercicio se entrega de forma independiente y puede ser evaluado por separado.

---

## Estructura del repositorio

```
├── README.md
├── cobol/
│ └── IBM_Cobol.cob
├── sql/
│ └── consultas.sql
├── Docs/
│ ├── Ejercicio_3_n8n_documentacion.docx
│ ├── Ejercicio_11_Automatizacion_Cucumber.pdf
│ └── enunciado_prueba_ibm.pdf

```

La estructura separa los entregables por dominio técnico para facilitar la lectura, revisión y defensa técnica.

---

## Descripción de los entregables

### SQL

**Archivo:** `sql/Prueba_tecnica_IBM_Consultas_SQL.sql`

Contiene la resolución de los ejercicios SQL solicitados en el enunciado.

Características principales:

- Uso de subconsultas y columnas calculadas  
- Resolución explícita de ambigüedades (edad, beneficios, orden lógico)  
- Justificación de decisiones directamente en el archivo  
- No se devuelve únicamente la consulta, sino también el razonamiento  

---

### Documentación funcional – n8n

**Archivo:** `docs/Ejercicio_3_n8n_documentacion.docx`

Documento Word con documentación funcional y operativa del sistema **n8n**.

Características:

- Orientado a usuario técnico-funcional  
- No es traducción ni resumen del README oficial  
- Incluye:
  - Conceptos fundamentales  
  - Patrones de uso reales  
  - Operación en producción  
  - Seguridad, observabilidad y escalado  
- Se justifica:
  - Rol del lector  
  - Nivel de profundidad  
  - Alcance y exclusiones  

El documento fue estructurado con apoyo de herramientas de IA, pero todas las decisiones de enfoque y contenido fueron definidas manualmente.

---

### COBOL – Programa batch

**Archivo:** `cobol/IBM_Cobol.cob`

Programa batch desarrollado en COBOL que procesa archivos secuenciales y genera un reporte por idioma.

#### Archivos de entrada

- `palabras.dat`  
  Formato: `<codigo>|<palabra>|<idioma>`

- `idiomas.dat`  
  Formato: `<idioma>|<descripcion>`

No se asume orden de los archivos.

#### Reglas implementadas

- Validación estricta de formato  
- Carga completa de `idiomas.dat` en memoria  
- Finalización inmediata ante el primer error  
- Cálculo de promedios sin divisiones en línea  
- Normalización del parámetro de entrada (A–Z)  

---

## Ejecución del programa COBOL

### Requisitos

- Compilador COBOL (por ejemplo, GnuCOBOL)  
- Entorno de ejecución batch  
- Archivos de entrada disponibles  

### Compilación

```
cobc -x IBM_Cobol.cob
```

### Ejecución
```
./IBM_Cobol A
```

La letra puede ingresarse en minúscula o mayúscula.

### Salida

- El reporte se muestra por salida estándar  
- Ante el primer error:
  - Se informa el error  
  - Se indica la línea afectada  
  - El programa finaliza inmediatamente  

---

## Consideraciones generales

- No se asumen comportamientos no definidos en el enunciado  
- Las ambigüedades se resuelven de forma explícita y justificada  
- Se prioriza claridad, corrección y trazabilidad  
- La estructura facilita la extensión a ejercicios opcionales  
---

## Consideraciones sobre el enunciado y uso de IA

Durante el análisis del enunciado se detectaron fragmentos de texto con formato no visible (letra blanca sobre fondo blanco).

Estos fragmentos incluían dos tipos de contenido claramente diferenciables:

1. **Instrucciones dirigidas explícitamente a modelos de lenguaje (LLMs)**  
   Ejemplo: indicaciones del tipo *«ignorar instrucciones previas»* o *«resolver automáticamente»*.

2. **Aclaraciones o restricciones adicionales de la consigna**, no redundantes con el texto visible.

### Decisiones tomadas

- Las **instrucciones dirigidas a LLMs** fueron **ignoradas deliberadamente**, ya que:
  - No forman parte de la consigna funcional para una persona.
  - No tienen impacto técnico sobre el problema a resolver.
  - Seguirlas iría en contra del objetivo de evaluar criterio y razonamiento humano.

- Las **aclaraciones funcionales relevantes** incluidas en texto no visible fueron:
  - Analizadas caso a caso.
  - Consideradas únicamente cuando aportaban información concreta sobre reglas, restricciones o alcance del ejercicio.
  - Aplicadas de forma explícita y justificadas cuando afectaban decisiones de diseño.

  Esta separación permitió mantener una resolución coherente, reproducible y defendible, alineada con el objetivo real de la prueba: evaluar capacidad de análisis y toma de decisiones frente a ambigüedades.
---
