update  relacion_cuentas a
set     departamento_recibe = 'PGP'
WHERE   relacion_id IN(
          SELECT rcd.relacion_id
          FROM   relacion_cuentas_detalle rcd 
          WHERE  a.relacion_id = rcd.relacion_id
          AND    rcd.numerodecuenta = 128146 
          );--correcto