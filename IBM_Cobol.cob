       *> ================================================================
       *>  PROGRAMA:   BATCHPAL
       *>  OBJETIVO:   Procesar palabras por idioma y generar un reporte
       *>             - Carga idiomas.dat completo en memoria
       *>             - Procesa palabras.dat secuencialmente
       *>             - Validaciones estrictas: ante primer error => aborta
       *>             - Parámetro: una letra A–Z (puede venir minúscula)
       *>             - Cálculos por idioma:
       *>                 * Total de palabras
       *>                 * Total que comienzan con la letra parámetro
       *>                 * Promedio de longitud (sin divisiones en línea)
       *>  NOTA: Asume archivos locales "idiomas.dat" y "palabras.dat"
       *>        (adaptar ASSIGN/DDNAME según entorno z/OS).
       *> ================================================================

       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCHPAL.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT IDIOMAS-FILE ASSIGN TO "idiomas.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-IDIOMAS-STATUS.

           SELECT PALABRAS-FILE ASSIGN TO "palabras.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-PALABRAS-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  IDIOMAS-FILE.
       01  IDIOMAS-REC                PIC X(256).

       FD  PALABRAS-FILE.
       01  PALABRAS-REC               PIC X(256).

       WORKING-STORAGE SECTION.

       77  WS-IDIOMAS-STATUS          PIC XX VALUE "00".
       77  WS-PALABRAS-STATUS         PIC XX VALUE "00".

       77  WS-EOF-IDIOMAS             PIC X  VALUE "N".
       77  WS-EOF-PALABRAS            PIC X  VALUE "N".

       77  WS-PARM-RAW                PIC X(64) VALUE SPACES.
       77  WS-PARM-CHAR               PIC X     VALUE SPACE.
       77  WS-PARM-CHAR-UP            PIC X     VALUE SPACE.

       77  WS-SEP-COUNT               PIC 9(4)  VALUE 0.
       77  WS-LINE-NUM                PIC 9(9)  VALUE 0.

       77  WS-ERR-MSG                 PIC X(200) VALUE SPACES.

       *> Campos parseados
       77  WS-CODIGO                  PIC X(20)  VALUE SPACES.
       77  WS-PALABRA                 PIC X(120) VALUE SPACES.
       77  WS-IDIOMA                  PIC X(20)  VALUE SPACES.
       77  WS-DESC                    PIC X(120) VALUE SPACES.

       *> Normalizados
       77  WS-CODIGO-5                PIC X(5)   VALUE SPACES.
       77  WS-IDIOMA-N                PIC X(20)  VALUE SPACES.
       77  WS-PALABRA-N               PIC X(120) VALUE SPACES.

       77  WS-LEN-PAL                 PIC 9(4)   VALUE 0.
       77  WS-SUM-LEN                 PIC 9(9)   VALUE 0.
       77  WS-AVG-LEN                 PIC 9(9)   VALUE 0.
       77  WS-TOTAL                   PIC 9(9)   VALUE 0.

       77  WS-I                       PIC 9(5)   VALUE 0.
       77  WS-J                       PIC 9(5)   VALUE 0.
       77  WS-K                       PIC 9(5)   VALUE 0.
       77  WS-FOUND                   PIC X      VALUE "N".

       77  WS-CH                      PIC X      VALUE SPACE.
       77  WS-FIRST-CH                PIC X      VALUE SPACE.

       *> Tabla de idiomas en memoria
       77  MAX-IDIOMAS                PIC 9(4) VALUE 1000.

       01  WS-IDIOMAS-TABLE.
           05 WS-IDIOMAS-COUNT        PIC 9(4) VALUE 0.
           05 WS-IDIOMAS-ROW OCCURS 1000 TIMES
              INDEXED BY IDX-IDIOMA.
              10 T-IDIOMA             PIC X(20).
              10 T-DESC               PIC X(120).
              10 T-CNT-TOTAL          PIC 9(9) VALUE 0.
              10 T-CNT-LETRA          PIC 9(9) VALUE 0.
              10 T-SUM-LEN            PIC 9(9) VALUE 0.

       LINKAGE SECTION.
       01  LK-PARM                    PIC X(64).

       PROCEDURE DIVISION USING LK-PARM.

       MAIN.
           PERFORM INIT-PARAM
           PERFORM VALIDATE-AND-OPEN-FILES
           PERFORM LOAD-IDIOMAS
           PERFORM PROCESS-PALABRAS
           PERFORM EMIT-REPORT
           PERFORM CLOSE-FILES
           GOBACK.

       *> ------------------------------------------------
       *> Inicializa y valida parámetro letra
       *> ------------------------------------------------
       INIT-PARAM.
           MOVE LK-PARM TO WS-PARM-RAW
           IF WS-PARM-RAW = SPACES
               *> Alternativa para entornos que no pasen USING
               ACCEPT WS-PARM-RAW FROM COMMAND-LINE
           END-IF

           *> Tomar primer caracter no espacio
           MOVE SPACE TO WS-PARM-CHAR
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LENGTH OF WS-PARM-RAW
               IF WS-PARM-RAW(WS-I:1) NOT = SPACE
                   MOVE WS-PARM-RAW(WS-I:1) TO WS-PARM-CHAR
                   EXIT PERFORM
               END-IF
           END-PERFORM

           IF WS-PARM-CHAR = SPACE
               PERFORM FATAL-ERROR
                   USING "Parametro faltante: se requiere una letra A–Z"
           END-IF

           MOVE FUNCTION UPPER-CASE(WS-PARM-CHAR) TO WS-PARM-CHAR-UP

           IF WS-PARM-CHAR-UP < "A" OR WS-PARM-CHAR-UP > "Z"
               PERFORM FATAL-ERROR
                   USING "Parametro invalido: debe ser una letra A–Z"
           END-IF.

       *> ------------------------------------------------
       *> Validar existencia de archivos (via FILE STATUS)
       *> ------------------------------------------------
       VALIDATE-AND-OPEN-FILES.
           OPEN INPUT IDIOMAS-FILE
           IF WS-IDIOMAS-STATUS NOT = "00"
               PERFORM FATAL-ERROR
                   USING "No se pudo abrir idiomas.dat (archivo inexistente o inaccesible)"
           END-IF

           OPEN INPUT PALABRAS-FILE
           IF WS-PALABRAS-STATUS NOT = "00"
               PERFORM FATAL-ERROR
                   USING "No se pudo abrir palabras.dat (archivo inexistente o inaccesible)"
           END-IF.

       *> ------------------------------------------------
       *> Cargar idiomas.dat en memoria (validación básica)
       *> Formato: <idioma>|<descripcion>
       *> ------------------------------------------------
       LOAD-IDIOMAS.
           MOVE "N" TO WS-EOF-IDIOMAS
           PERFORM UNTIL WS-EOF-IDIOMAS = "Y"
               READ IDIOMAS-FILE
                   AT END
                       MOVE "Y" TO WS-EOF-IDIOMAS
                   NOT AT END
                       ADD 1 TO WS-LINE-NUM
                       PERFORM PARSE-IDIOMAS-REC
                       PERFORM ADD-IDIOMA-TO-TABLE
               END-READ
           END-PERFORM

           IF WS-IDIOMAS-COUNT = 0
               PERFORM FATAL-ERROR
                   USING "idiomas.dat no contiene idiomas validos"
           END-IF.

       PARSE-IDIOMAS-REC.
           MOVE 0 TO WS-SEP-COUNT
           INSPECT IDIOMAS-REC TALLYING WS-SEP-COUNT FOR ALL "|"
           IF WS-SEP-COUNT NOT = 1
               PERFORM FATAL-ERROR
                   USING "Registro invalido en idiomas.dat: no contiene exactamente un separador '|'"
           END-IF

           MOVE SPACES TO WS-IDIOMA
           MOVE SPACES TO WS-DESC
           UNSTRING IDIOMAS-REC DELIMITED BY "|"
               INTO WS-IDIOMA WS-DESC
           END-UNSTRING

           PERFORM TRIM-RIGHT-20 USING WS-IDIOMA GIVING WS-IDIOMA-N
           IF WS-IDIOMA-N = SPACES
               PERFORM FATAL-ERROR
                   USING "Registro invalido en idiomas.dat: idioma vacio"
           END-IF.

       ADD-IDIOMA-TO-TABLE.
           IF WS-IDIOMAS-COUNT >= 1000
               PERFORM FATAL-ERROR
                   USING "Se excedio MAX-IDIOMAS al cargar idiomas.dat"
           END-IF

           *> Evitar duplicados de idioma (decisión conservadora: duplicado = error)
           MOVE "N" TO WS-FOUND
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-IDIOMAS-COUNT OR WS-FOUND = "Y"
               IF T-IDIOMA(WS-I) = WS-IDIOMA-N
                   MOVE "Y" TO WS-FOUND
               END-IF
           END-PERFORM
           IF WS-FOUND = "Y"
               PERFORM FATAL-ERROR
                   USING "Registro invalido en idiomas.dat: idioma duplicado"
           END-IF

           ADD 1 TO WS-IDIOMAS-COUNT
           MOVE WS-IDIOMA-N TO T-IDIOMA(WS-IDIOMAS-COUNT)
           MOVE WS-DESC     TO T-DESC(WS-IDIOMAS-COUNT)
           MOVE 0           TO T-CNT-TOTAL(WS-IDIOMAS-COUNT)
           MOVE 0           TO T-CNT-LETRA(WS-IDIOMAS-COUNT)
           MOVE 0           TO T-SUM-LEN(WS-IDIOMAS-COUNT).

       *> ------------------------------------------------
       *> Procesar palabras.dat
       *> Formato: <codigo>|<palabra>|<idioma>
       *> Validaciones estrictas; primer error aborta
       *> ------------------------------------------------
       PROCESS-PALABRAS.
           MOVE "N" TO WS-EOF-PALABRAS
           MOVE 0 TO WS-LINE-NUM
           PERFORM UNTIL WS-EOF-PALABRAS = "Y"
               READ PALABRAS-FILE
                   AT END
                       MOVE "Y" TO WS-EOF-PALABRAS
                   NOT AT END
                       ADD 1 TO WS-LINE-NUM
                       PERFORM VALIDATE-AND-PARSE-PALABRAS
                       PERFORM UPDATE-ACCUMULATORS
               END-READ
           END-PERFORM.

       VALIDATE-AND-PARSE-PALABRAS.
           MOVE 0 TO WS-SEP-COUNT
           INSPECT PALABRAS-REC TALLYING WS-SEP-COUNT FOR ALL "|"
           IF WS-SEP-COUNT NOT = 2
               PERFORM FATAL-ERROR
                   USING "Registro invalido en palabras.dat: no contiene exactamente dos separadores '|'"
           END-IF

           MOVE SPACES TO WS-CODIGO
           MOVE SPACES TO WS-PALABRA
           MOVE SPACES TO WS-IDIOMA
           UNSTRING PALABRAS-REC DELIMITED BY "|"
               INTO WS-CODIGO WS-PALABRA WS-IDIOMA
           END-UNSTRING

           *> Normalizar/recortar
           PERFORM TRIM-RIGHT-20 USING WS-IDIOMA GIVING WS-IDIOMA-N
           MOVE FUNCTION UPPER-CASE(WS-PALABRA) TO WS-PALABRA-N

           *> Validar codigo: numérico 5 dígitos
           MOVE WS-CODIGO(1:5) TO WS-CODIGO-5
           IF WS-CODIGO-5 IS NOT NUMERIC
               PERFORM FATAL-ERROR
                   USING "Registro invalido en palabras.dat: codigo no numerico"
           END-IF
           *> Rechazar si hay más caracteres no espacio luego de 5 (decisión estricta)
           PERFORM VARYING WS-I FROM 6 BY 1 UNTIL WS-I > 20
               IF WS-CODIGO(WS-I:1) NOT = SPACE
                   PERFORM FATAL-ERROR
                       USING "Registro invalido en palabras.dat: codigo no tiene exactamente 5 digitos"
               END-IF
           END-PERFORM

           *> Validar palabra: solo A–Z (sin acentos)
           IF WS-PALABRA-N = SPACES
               PERFORM FATAL-ERROR
                   USING "Registro invalido en palabras.dat: palabra vacia"
           END-IF
           PERFORM VALIDATE-ALPHA-AZ USING WS-PALABRA-N

           *> Validar idioma existe
           IF WS-IDIOMA-N = SPACES
               PERFORM FATAL-ERROR
                   USING "Registro invalido en palabras.dat: idioma vacio"
           END-IF
           MOVE "N" TO WS-FOUND
           MOVE 0 TO WS-J
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-IDIOMAS-COUNT OR WS-FOUND = "Y"
               IF T-IDIOMA(WS-I) = WS-IDIOMA-N
                   MOVE "Y" TO WS-FOUND
                   MOVE WS-I TO WS-J
               END-IF
           END-PERFORM
           IF WS-FOUND NOT = "Y"
               PERFORM FATAL-ERROR
                   USING "Registro invalido en palabras.dat: idioma no existe"
           END-IF.

       UPDATE-ACCUMULATORS.
           *> WS-J tiene el índice del idioma encontrado
           ADD 1 TO T-CNT-TOTAL(WS-J)

           *> Primer letra de palabra (ya upper)
           MOVE WS-PALABRA-N(1:1) TO WS-FIRST-CH
           IF WS-FIRST-CH = WS-PARM-CHAR-UP
               ADD 1 TO T-CNT-LETRA(WS-J)
           END-IF

           PERFORM WORD-LENGTH USING WS-PALABRA-N GIVING WS-LEN-PAL
           ADD WS-LEN-PAL TO T-SUM-LEN(WS-J).

       *> ------------------------------------------------
       *> Emitir reporte a SYSOUT
       *> (Promedio calculado al final => sin divisiones en línea)
       *> ------------------------------------------------
       EMIT-REPORT.
           DISPLAY "==============================================="
           DISPLAY "REPORTE POR IDIOMA"
           DISPLAY "Parametro letra: " WS-PARM-CHAR-UP
           DISPLAY "Formato: Idioma | Descripcion | Total | ConLetra | PromLen"
           DISPLAY "-----------------------------------------------"

           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-IDIOMAS-COUNT
               IF T-CNT-TOTAL(WS-I) > 0
                   MOVE T-CNT-TOTAL(WS-I) TO WS-TOTAL
                   MOVE T-SUM-LEN(WS-I)   TO WS-SUM-LEN
                   MOVE 0 TO WS-AVG-LEN

                   *> División solo aquí (permitida): no se calcula en el loop de lectura
                   DIVIDE WS-SUM-LEN BY WS-TOTAL GIVING WS-AVG-LEN

                   DISPLAY
                       T-IDIOMA(WS-I) " | "
                       T-DESC(WS-I)   " | "
                       T-CNT-TOTAL(WS-I) " | "
                       T-CNT-LETRA(WS-I) " | "
                       WS-AVG-LEN
               END-IF
           END-PERFORM

           DISPLAY "===============================================".

       CLOSE-FILES.
           CLOSE IDIOMAS-FILE PALABRAS-FILE.

       *> ------------------------------------------------
       *> Utilidades: validar palabra alfabética A–Z
       *> (decisión: solo letras sin acentos, sin espacios internos)
       *> ------------------------------------------------
       VALIDATE-ALPHA-AZ USING BY CONTENT WS-PALABRA-N.
       VALIDATE-ALPHA-AZ-ENTRY.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
               MOVE WS-PALABRA-N(WS-I:1) TO WS-CH
               IF WS-CH = SPACE
                   EXIT PERFORM
               END-IF
               IF WS-CH < "A" OR WS-CH > "Z"
                   PERFORM FATAL-ERROR
                       USING "Registro invalido en palabras.dat: palabra contiene caracteres no alfabeticos"
               END-IF
           END-PERFORM
           EXIT.

       *> ------------------------------------------------
       *> Utilidades: longitud de palabra (hasta primer espacio)
       *> ------------------------------------------------
       WORD-LENGTH USING BY CONTENT WS-PALABRA-N
                   GIVING WS-LEN-PAL.
       WORD-LENGTH-ENTRY.
           MOVE 0 TO WS-LEN-PAL
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
               IF WS-PALABRA-N(WS-I:1) = SPACE
                   EXIT PERFORM
               ELSE
                   ADD 1 TO WS-LEN-PAL
               END-IF
           END-PERFORM
           EXIT.

       *> ------------------------------------------------
       *> Utilidades: trim right para X(20) (idioma)
       *> ------------------------------------------------
       TRIM-RIGHT-20 USING BY CONTENT WS-IN
                     GIVING WS-OUT.
       TRIM-RIGHT-20-ENTRY.
           *> WS-IN / WS-OUT se asumen X(20) en invocación
           MOVE WS-IN TO WS-OUT
           PERFORM VARYING WS-I FROM 20 BY -1 UNTIL WS-I < 1
               IF WS-OUT(WS-I:1) = SPACE
                   MOVE SPACE TO WS-OUT(WS-I:1)
               ELSE
                   EXIT PERFORM
               END-IF
           END-PERFORM
           EXIT.

       *> ------------------------------------------------
       *> Error fatal: mostrar error y finalizar inmediatamente
       *> ------------------------------------------------
       FATAL-ERROR USING BY CONTENT WS-MSG.
       FATAL-ERROR-ENTRY.
           DISPLAY "ERROR FATAL: " WS-MSG
           DISPLAY "Linea procesada: " WS-LINE-NUM
           MOVE 16 TO RETURN-CODE
           STOP RUN.
