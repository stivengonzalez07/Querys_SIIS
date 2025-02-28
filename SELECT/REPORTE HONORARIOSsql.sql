select 
cl.cuenta_liquidacion_qx_id,
cl.ingreso,
cl.numerodecuenta,
cl.fecha_cirugia,
cl.duracion_cirugia,
cl.tipo_sala_id,
cl.tipo_id_ayudante,
cl.ayudante_id,
pa.nombre as nombre_ayudante,
qx.tipo_id_cirujano,
qx.cirujano_id,
pc.nombre as nombre_cirujano,
cl.tipo_id_anestesiologo,
cl.anestesiologo_id,
pb.nombre as nombre_anestesiologo,
cl.fecha_registro,
cl.usuario_id,
s.nombre as nombre_usuario,
cl.cargo_principal,
 CASE WHEN cl.estado= '0' THEN 'NO LIQUIDADA'
     WHEN cl.estado='1' THEN 'LIQUIDADA'
     WHEN cl.estado= '2' THEN 'FACTURADA'
     WHEN cl.estado= '3' THEN 'CANCELADA'
     END AS estado,    
cl.sw_derechos_cirujano,
cl.sw_derechos_anestesiologo,
cl.sw_derechos_ayudante,
cl.sw_derechos_sala,
cl.sw_derechos_materiales,
cl.programacion_id,
cl.departamento

FROM
cuentas_liquidaciones_qx cl
FULL OUTER JOIN qx_programaciones qx on (cl.programacion_id=qx.programacion_id)
FULL OUTER JOIN profesionales pa on (cl.ayudante_id=pa.tercero_id)
FULL OUTER JOIN profesionales pb on (cl.anestesiologo_id=pb.tercero_id)
FULL OUTER JOIN profesionales pc on (qx.cirujano_id=pc.tercero_id)
FULL OUTER JOIN system_usuarios s on (cl.usuario_id=s.usuario_id)
WHERE
cl.fecha_registro 
--BETWEEN _1 AND _2
BETWEEN '2022-02-28' AND '2022-02-28'