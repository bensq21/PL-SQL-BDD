--ALVARO VAZQUEZ GONZALEZ
SET SERVEROUTPUT ON;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ListarCiudades
IS

    CURSOR C_CIUDAD IS
        SELECT DISTINCT EST_lOCALIDAD
        FROM ESTUDIO
    ;
    
    CURSOR C_ESTUDIO(C_CIUDAD ESTUDIO.EST_lOCALIDAD%TYPE) IS
        SELECT EST_ID ID, EST_NOMBRE NOMBRE, TO_CHAR(EST_FUNDACION,'YYYY') "ANO_FUNDACION", EST_PRESUPUESTO PRESUPUESTO
        FROM ESTUDIO
        WHERE UPPER(EST_lOCALIDAD)=UPPER(C_CIUDAD)
    ;
    
BEGIN
    
    FOR REG_1 IN C_CIUDAD LOOP
    
        DBMS_OUTPUT.PUT_LINE( ' ');
        DBMS_OUTPUT.PUT_LINE( ' ');
        DBMS_OUTPUT.PUT_LINE( REG_1.EST_lOCALIDAD);
        DBMS_OUTPUT.PUT_LINE( '--------------------------------------------------');
        
        DBMS_OUTPUT.PUT_LINE( '-');
        DBMS_OUTPUT.PUT_LINE( 'ID       ESTUDIO                     AÑO DE FUNDACION            PRESUPUESTO');
        DBMS_OUTPUT.PUT_LINE( '-------- --------------------------- --------------------------- -------------');

        FOR REG_2 IN C_ESTUDIO(REG_1.EST_lOCALIDAD) LOOP

            DBMS_OUTPUT.PUT_LINE( REG_2.ID || '     ' || REG_2.NOMBRE || '            ' || REG_2.ANO_FUNDACION || '                     ' || REG_2.PRESUPUESTO);

        END LOOP;
        
    END LOOP;

END;
/

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE ListarEstudio(P_ESTUDIO ESTUDIO.EST_NOMBRE%TYPE)
IS
    
    CURSOR C_ESTUDIO IS
        SELECT EST_ID COD, EST_NOMBRE NOMBRE
        FROM ESTUDIO
        WHERE UPPER(EST_NOMBRE)=UPPER(P_ESTUDIO)
    ;
    
    CURSOR C_PELI(C_ESTUDIO ESTUDIO.EST_ID%TYPE) IS
        SELECT PELI.PELI_ID COD, PELI.PELI_TITULO, TO_CHAR(PELI.PELI_ANO, 'YYYY') ANO, DIR.DIR_NOMBRE || ', ' ||  DIR.DIR_APELLIDOS AS "DIRECTOR",  
                ACT.ACT_NOMBRE || ', ' ||  ACT.ACT_APELLIDOS AS "ACTOR_PRINCIPAL", GUI.GUI_NOMBRE || ', ' ||  GUI.GUI_APELLIDOS AS "GUIONISTA"
        FROM PELICULA PELI, DIRECTOR DIR, GUIONISTA GUI, ACTOR ACT, ACTUAN
        WHERE DIR.DIR_DNI=PELI.PELI_DIRECTOR AND GUI.GUI_DNI=PELI.PELI_GUIONISTA AND PELI.PELI_ID=ACTUAN.ACTUA_PELI AND ACTUAN.ACTUA_PRINCIPAL=ACT.ACT_DNI
        AND PELI.PELI_ESTUDIO=C_ESTUDIO
    ;

BEGIN
    
    FOR REG_1 IN C_ESTUDIO LOOP
    
        DBMS_OUTPUT.PUT_LINE( 'NOMBRE ESTUDIO CINEMATOGRÁFICO: '|| REG_1.NOMBRE);
        DBMS_OUTPUT.PUT_LINE( '--------------------------------------------------');
        
        DBMS_OUTPUT.PUT_LINE( '-');
        DBMS_OUTPUT.PUT_LINE( 'ID       TITULO                      AÑO DE ESTRENO              DIRECTOR/A                    ACTOR/ACTRIZ PRINCIPAL                         GUIONISTA');
        DBMS_OUTPUT.PUT_LINE( '-------- --------------------------- --------------------------- --------------------------- --------------------------------------- ----------------------------');

        FOR REG_2 IN C_PELI(REG_1.COD) LOOP

        DBMS_OUTPUT.PUT_LINE( REG_2.COD || '       ' || REG_2.PELI_TITULO || '                      ' || REG_2.ANO || '              ' || REG_2.DIRECTOR || '                    ' || REG_2.ACTOR_PRINCIPAL || '                         ' || REG_2.GUIONISTA || '');

        END LOOP;
        
    END LOOP;

end;
/

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ListarDirectores(P_PELI PELICULA.PELI_ID%TYPE)
RETURN DIRECTOR.DIR_SALARIO%TYPE
IS
    
    CURSOR C_DIRECTOR IS
        SELECT DIR.DIR_DNI DNI, DIR.DIR_NOMBRE || ', ' ||  DIR.DIR_APELLIDOS AS "DIRECTOR", DIR.DIR_TELEFONO TELEFONO, DIR.DIR_DIRECCION DIRECCION, DIR.DIR_SALARIO SALARIO
        FROM PELICULA PELI, DIRECTOR DIR
        WHERE PELI.PELI_DIRECTOR=DIR.DIR_DNI AND PELI.PELI_ID=P_PELI
    ;
    
BEGIN
    
    FOR REG IN C_DIRECTOR LOOP
    
        DBMS_OUTPUT.PUT_LINE( '-');
        DBMS_OUTPUT.PUT_LINE( 'DNI      DIRECTOR/A                  TELEFONO                    DIRECCION                   SALARIO                  ');
        DBMS_OUTPUT.PUT_LINE( '-------- --------------------------- --------------------------- --------------------------- -----------------------------');
        DBMS_OUTPUT.PUT_LINE( REG.DNI || '   ' || REG.DIRECTOR || '                      ' || REG.TELEFONO || '              ' || REG.DIRECCION || '                    ' || REG.SALARIO);
        RETURN REG.SALARIO;
        
    END LOOP;
    
END;
/

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ListarGuionistas(P_PELI PELICULA.PELI_ID%TYPE)
RETURN GUIONISTA.GUI_SALARIO%TYPE
IS
    
    CURSOR C_GUIONISTA IS
        SELECT GUI.GUI_DNI DNI, GUI.GUI_NOMBRE || ', ' ||  GUI.GUI_APELLIDOS AS "GUIONISTA", GUI.GUI_TELEFONO TELEFONO, GUI.GUI_DIRECCION DIRECCION, GUI.GUI_SALARIO SALARIO
        FROM PELICULA PELI, GUIONISTA GUI
        WHERE PELI.PELI_GUIONISTA=GUI.GUI_DNI AND PELI.PELI_ID=P_PELI
    ;
    
BEGIN
    
    FOR REG IN C_GUIONISTA LOOP
    
        DBMS_OUTPUT.PUT_LINE( '-');
        DBMS_OUTPUT.PUT_LINE( 'DNI      GUIONISTA                  TELEFONO                    DIRECCION                   SALARIO                  ');
        DBMS_OUTPUT.PUT_LINE( '-------- --------------------------- --------------------------- --------------------------- -----------------------------');
        DBMS_OUTPUT.PUT_LINE( REG.DNI || '   ' || REG.GUIONISTA || '     ' || REG.TELEFONO || '              ' || REG.DIRECCION || '                    ' || REG.SALARIO);
        RETURN REG.SALARIO;
        
    END LOOP;
    
END;
/

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ListarActores(P_PELI PELICULA.PELI_ID%TYPE)
RETURN ACTOR.ACT_SALARIO%TYPE
IS

    F_SUMASALARIO ACTOR.ACT_SALARIO%TYPE := 0;
    
    CURSOR C_ACTOR IS
        SELECT ACT.ACT_DNI DNI, ACT.ACT_NOMBRE || ', ' ||  ACT.ACT_APELLIDOS AS "ACTOR", ACT.ACT_TELEFONO TELEFONO, ACT.ACT_DIRECCION DIRECCION, ACT.ACT_SALARIO SALARIO
        FROM PELICULA PELI, ACTOR ACT, ACTUAN ACTU
        WHERE PELI.PELI_ID=ACTU.ACTUA_PELI AND ACTU.ACTUA_DNI=ACT.ACT_DNI
        AND PELI.PELI_ID=P_PELI
    ;
    
BEGIN
    
    DBMS_OUTPUT.PUT_LINE( '-');
    DBMS_OUTPUT.PUT_LINE( 'DNI      ACTOR/ACTRIZ                  TELEFONO                    DIRECCION                   SALARIO                  ');
    DBMS_OUTPUT.PUT_LINE( '-------- --------------------------- --------------------------- --------------------------- -----------------------------');
    
    FOR REG IN C_ACTOR LOOP
    
        DBMS_OUTPUT.PUT_LINE( REG.DNI || '     ' || REG.ACTOR || '      ' || REG.TELEFONO || '              ' || REG.DIRECCION || '                    ' || REG.SALARIO);
        F_SUMASALARIO := F_SUMASALARIO + REG.SALARIO;
        
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE( '-');
    DBMS_OUTPUT.PUT_LINE( 'COSTE DE ACTORES: ' || F_SUMASALARIO);
    RETURN F_SUMASALARIO;
    
END;
/

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION CompruebaPresupuesto(P_PELI PELICULA.PELI_ID%TYPE)
RETURN BOOLEAN
IS
    
    F_PRESUPUESTO ESTUDIO.EST_PRESUPUESTO%TYPE;
    F_COSTE ESTUDIO.EST_PRESUPUESTO%TYPE;
    
BEGIN
    
    
    
    SELECT EST_PRESUPUESTO INTO F_PRESUPUESTO
        FROM PELICULA PELI, ESTUDIO EST
        WHERE PELI.PELI_ESTUDIO=EST.EST_ID AND PELI.PELI_ID=P_PELI
    ;
    
    F_COSTE := ListarDirectores(P_PELI) + ListarActores(P_PELI) + ListarGuionistas(P_PELI);
    
    DBMS_OUTPUT.PUT_LINE( ' ');
    DBMS_OUTPUT.PUT_LINE( 'PRESUPUESETO: ' || F_PRESUPUESTO);
    DBMS_OUTPUT.PUT_LINE( 'COSTE: ' || F_COSTE);
    
    IF (F_PRESUPUESTO >= F_COSTE) THEN
        
        RETURN TRUE;        
        
    ELSE
    
        RETURN FALSE;
    
    END IF;
    
END;
/


----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE

    ESTUD ESTUDIO.EST_NOMBRE%TYPE := '&nombre_estudio';
    TIT_PELI PELICULA.PELI_TITULO%TYPE := '&id_pelicula';
    ID_PELI PELICULA.PELI_ID%TYPE;

BEGIN

    LISTARCIUDADES;
    DBMS_OUTPUT.PUT_LINE( ' ');
    DBMS_OUTPUT.PUT_LINE( ' ');
    LISTARESTUDIO(ESTUD);
    
    SELECT PELI_ID INTO ID_PELI
        FROM PELICULA
        WHERE UPPER(PELI_TITULO)=UPPER(TIT_PELI)
    ;
    
    DBMS_OUTPUT.PUT_LINE( ' ');
    IF(COMPRUEBAPRESUPUESTO(ID_PELI)) THEN
    
        DBMS_OUTPUT.PUT_LINE( 'PRESUPUESETO ACEPTADO');
    
    ELSE
    
        DBMS_OUTPUT.PUT_LINE( 'PRESUPUESETO DENEGADO');
    
    END IF;

END;
/
