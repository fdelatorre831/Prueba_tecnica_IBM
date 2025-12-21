# Prueba Técnica IBM – Consulting Students

Francisco de la Torre  
Email: fran.delatorre01@gmail.com

---

## 1. Descripción general

Este repositorio contiene la resolución de la prueba técnica propuesta por IBM para el proceso de selección “Consulting Students”.

La entrega cubre múltiples perfiles técnicos (SQL, Automatización / Documentación funcional y COBOL) y prioriza:

- Capacidad de análisis frente a consignas ambiguas
- Validaciones estrictas y decisiones justificadas
- Claridad conceptual y técnica
- Separación entre solución técnica y explicación funcional

No se trata de un proyecto productivo, sino de una **demostración de criterio técnico y razonamiento**.

---

## 2. Estructura del repositorio

```
├── README.md
├── cobol/
│ └── IBM_Cobol.cob
├── sql/
│ └── consultas.sql
├── docs/
│ ├── Ejercicio_3_n8n_documentacion.docx
│ ├── Ejercicio_11_Automatizacion_Cucumber.pdf
│ └── enunciado_prueba_ibm.pdf

---

## 3. Contenido por ejercicio

### 3.1 SQL – Consultas

**Ruta:** `sql/consultas.sql`

Incluye la resolución de los ejercicios SQL solicitados en el enunciado.

Características:
- Uso de subconsultas y filtros complejos
- Columnas calculadas justificadas
- Manejo explícito de ambigüedades (edad, beneficios, orden lógico)
- Decisiones documentadas en el propio archivo SQL

No se devuelve únicamente la consulta: se prioriza legibilidad y explicación.

---

### 3.2 Documentación funcional – n8n

**Ruta:** `docs/Ejercicio_3_n8n_documentacion.docx`

Documento Word con documentación funcional y operativa del sistema n8n.

Características clave:
- No es traducción ni resumen del README oficial
- Orientado a **usuario técnico-funcional**
- Incluye:
  - Conceptos fundamentales
  - Patrones de uso reales
  - Operación en producción
  - Seguridad, observabilidad y escalado
- Se justifica explícitamente:
  - Rol del lector
  - Nivel de profundidad
  - Alcance y exclusiones

El documento fue estructurado con apoyo de IA, pero todas las decisiones de enfoque fueron definidas manualmente.

---

### 3.3 COBOL – Programa batch

**Ruta:** `cobol/IBM_Cobol.cob`

Programa batch desarrollado en COBOL que procesa archivos secuenciales y genera un reporte por idioma.

#### Archivos de entrada

- `palabras.dat`  
  Formato: `<codigo>|<palabra>|<idioma>`

- `idiomas.dat`  
  Formato: `<idioma>|<descripcion>`

El orden de los archivos no se asume.

#### Reglas implementadas

- Validación estricta de formato
- Carga completa de `idiomas.dat` en memoria
- Finalización inmediata ante el primer error
- Cálculo de promedios sin divisiones en línea
- Normalización del parámetro de entrada (A–Z)

---

## 4. Ejecución del programa COBOL

### Requisitos

- Compilador COBOL (ej. GnuCOBOL)
- Entorno batch
- Archivos de entrada disponibles

### Compilación
```
cobc -x IBM_Cobol.cob
```


## 🚀 Cómo ejecutar el programa COBOL

### Requisitos

* Compilador COBOL (por ejemplo, GnuCOBOL)
* Entorno de ejecución batch
* Archivos de entrada:

  * palabras.dat
  * idiomas.dat

### Formato de los archivos de entrada
```
idiomas.dat <idioma>|<descripcion>

palabras.dat <codigo>|<palabra>|<idioma>
```
### Compilación

Ejemplo utilizando GnuCOBOL:
```
cobc -x IBM_Cobol.cob
```
### Ejecución
```
./IBM_Cobol A
```

La letra puede ingresarse en minúscula o mayúscula.

### Salida

- Reporte por salida estándar
- Ante error:
  - Mensaje descriptivo
  - Línea afectada
  - Terminación inmediata del proceso

---

## 5. Consideraciones de diseño

- No se asumen comportamientos no definidos en el enunciado
- Las ambigüedades se resuelven de forma explícita y justificada
- Se prioriza corrección, claridad y trazabilidad
- El diseño facilita extensión a ejercicios opcionales (containerización, despliegue, testing)

---

## 6. Notas finales

Este repositorio fue construido siguiendo el espíritu de la prueba: **pensar antes de implementar**.

Cada entrega puede defenderse de forma independiente frente a un perfil técnico distinto.
