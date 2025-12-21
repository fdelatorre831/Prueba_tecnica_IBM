/*
Ejercicio 1 —

Supuestos y decisiones explícitas según consigna:

Campos no obligatorios:
No se asume obligatoriedad de ningún campo.
Se excluyen personas sin fecha_nacimiento, ya que no es posible calcular la edad
de forma consistente.
El ingreso_mensual NULL no permite clasificar el segmento socioeconómico;
solo se considera como 'Vulnerable' si la persona recibe al menos un beneficio
relevante. En caso contrario, el registro se excluye.

Cálculo de edad:
Se calcula en años completos (truncado), criterio administrativo estándar,
evitando “cumplimientos anticipados”.

Búsqueda de fragmentos en nombres:
Se realiza de forma case-insensitive, ya que no se define sensibilidad
y es el comportamiento esperado.

Longitud de apellido (5–20):
Se mide en caracteres Unicode (no bytes), porque el término “caracter”
es ambiguo y Unicode representa la unidad semántica correcta.

Índice de desarrollo:
El indice_desarrollo puede no estar normalizado.
Se utiliza el promedio aritmético dinámico al momento de ejecución,
ya que la consigna indica que puede cambiar y no define escalas alternativas.

Beneficios “relevantes”:
Se consideran únicamente los beneficios otorgados en los últimos 5 años
para los cálculos.
No se discrimina por tipo_beneficio, ya que no se definen criterios adicionales.
Beneficios antiguos no invalidan a la persona, dado que asumirlo sería
una suposición no indicada por la consigna.

Exclusión desempleado + más de un beneficio:
La exclusión se evalúa después de computar el conteo de beneficios relevantes,
ya que antes no es posible decidir correctamente.

Uniones entre tablas:
Se utilizan LEFT JOIN hacia los agregados de beneficios para evitar excluir
personas por ausencia de datos, respetando que los campos no son obligatorios.
La relación Personas–Localidades se resuelve mediante JOIN explícito.

Orden de segmento_socioeconomico:
No es lexicográfico.
Se utiliza un orden semántico: Vulnerable, Medio, Alto,
siguiendo un gradiente de vulnerabilidad social y prioridad analítica.

Esquema de pasos:
1. Calcular el promedio de indice_desarrollo en Localidades (subquery/CTE).
2. Calcular beneficios relevantes (últimos 5 años) por persona: count(*) (subquery/CTE).
3. Unir Personas → Localidades y Personas → agregados de beneficios.
4. Aplicar filtros: longitud de apellido, fragmentos de nombre, edad ≥ 25,
   departamento ≠ Capital, indice_desarrollo > promedio.
5. Aplicar exclusión: estado_laboral = 'Desempleado' AND beneficios_relevantes > 1.
6. Calcular segmento_socioeconomico mediante CASE.
7. Ordenar por segmento_socioeconomico (orden semántico),
   edad DESC y apellido ASC.
*/


/* Ejercicio 1*/

WITH
avg_loc AS (
  SELECT AVG(COALESCE(indice_desarrollo, 0)) AS avg_indice
  FROM Localidades
),
ben5 AS (
  SELECT
    persona_id,
    COUNT(*) AS cnt_ben_5y
  FROM Beneficios
  WHERE fecha_otorgamiento >= (CURRENT_DATE - INTERVAL '5 years')
  GROUP BY persona_id
)
SELECT
  p.apellidos || ', ' || p.nombres AS nombre_completo,
  l.nombre_localidad,
  l.departamento,
  EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.fecha_nacimiento))::int AS edad_anios,
  CASE
    WHEN (p.ingreso_mensual IS NOT NULL AND p.ingreso_mensual < 1500)
         OR COALESCE(b.cnt_ben_5y, 0) >= 1
      THEN 'Vulnerable'
    WHEN p.ingreso_mensual BETWEEN 1500 AND 4000
         AND COALESCE(b.cnt_ben_5y, 0) = 0
      THEN 'Medio'
    WHEN p.ingreso_mensual > 4000
         AND COALESCE(b.cnt_ben_5y, 0) = 0
      THEN 'Alto'
    ELSE NULL
  END AS segmento_socioeconomico
FROM Personas p
JOIN Localidades l
  ON l.id_localidad = p.localidad_id
LEFT JOIN ben5 b
  ON b.persona_id = p.id_persona
CROSS JOIN avg_loc a
WHERE
  -- 1) apellido entre 5 y 20 caracteres (Unicode, depende del motor; en PG LENGTH cuenta caracteres)
  LENGTH(p.apellidos) BETWEEN 5 AND 20
  -- 2) nombre contiene fragmentos (case-insensitive)
  AND (
    p.nombres ILIKE '%Mar%' OR
    p.nombres ILIKE '%Luis%' OR
    p.nombres ILIKE '%Ana%'
  )
  -- 3) edad >= 25 (excluye NULL)
  AND p.fecha_nacimiento IS NOT NULL
  AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.fecha_nacimiento))::int >= 25
  -- 4) localidad constraints
  AND COALESCE(l.departamento, '') <> 'Capital'
  AND COALESCE(l.indice_desarrollo, 0) > a.avg_indice
  -- 5) excluir desempleado con >1 beneficio (relevante)
  AND NOT (
    p.estado_laboral = 'Desempleado'
    AND COALESCE(b.cnt_ben_5y, 0) > 1
  )
  -- evitar filas sin segmento (ingreso NULL sin beneficios)
  AND (
    (p.ingreso_mensual IS NOT NULL)
    OR COALESCE(b.cnt_ben_5y, 0) >= 1
  )
ORDER BY
  CASE segmento_socioeconomico
    WHEN 'Vulnerable' THEN 1
    WHEN 'Medio' THEN 2
    WHEN 'Alto' THEN 3
    ELSE 4
  END,
  edad_anios DESC,
  p.apellidos ASC;
  
  
/*
Ejercicio 2

Mayúsculas/minúsculas: se normaliza con LOWER() porque no se define; evita duplicados artificiales.

Espacios extremos: TRIM() porque suelen ser errores de carga.

Caracteres especiales: se mantienen; no hay regla que indique eliminarlos. El objetivo es “apellido” tal como está registrado; limpiar demasiado sería inventar negocio.

Esquema de pasos

Normalizar apellido: LOWER(TRIM(apellidos)).

Filtrar por longitud ≥ 8.

Agrupar y quedarme con los que aparecen una sola vez.

Orden alfabético.
*/

  /* Ejercicio 2*/

WITH norm AS (
  SELECT LOWER(TRIM(apellidos)) AS apellido_norm
  FROM Personas
  WHERE apellidos IS NOT NULL
)
SELECT apellido_norm AS apellido
FROM norm
WHERE LENGTH(apellido_norm) >= 8
GROUP BY apellido_norm
HAVING COUNT(*) = 1
ORDER BY apellido_norm ASC;

