/*
Ejercicio 1 —

Cálculo de edad: años completos (truncado), porque es el estándar administrativo; evita “cumplimientos anticipados”.

Búsqueda de fragmentos en nombres: case-insensitive, porque no se define sensibilidad y es el comportamiento esperado.

Longitud de apellido (5–20): caracteres Unicode (no bytes), porque “caracter” es ambiguo; Unicode es semántico.

Promedio de indice_desarrollo: dinámico al momento de ejecución; el enunciado dice que puede cambiar.

Beneficios “relevantes”: solo los de últimos 5 años (ventana) “para los cálculos”; beneficios antiguos no invalidan a la persona porque no está definido y sería una suposición fuerte.

Exclusión desempleado + >1 beneficio: se evalúa después de computar el conteo de beneficios relevantes; antes no se puede decidir correctamente.

Orden de segmento_socioeconomico: no lexicográfico. Uso orden semántico: Vulnerable, Medio, Alto (gradiente de vulnerabilidad social y prioridad analítica).

Esquema de pasos

Calcular promedio de indice_desarrollo en Localidades (subquery/CTE).

Calcular beneficios relevantes (últimos 5 años) por persona: count(*) (subquery/CTE).

Unir Personas → Localidades (INNER JOIN) y Personas → agregados de beneficios (LEFT JOIN).

Aplicar filtros: longitud apellido, fragmentos nombre, edad ≥ 25, departamento ≠ Capital, indice > promedio.

Aplicar exclusión: desempleado AND beneficios_relevantes > 1.

Calcular segmento_socioeconomico con CASE.

Ordenar por orden semántico de segmento, edad DESC, apellido ASC.
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
