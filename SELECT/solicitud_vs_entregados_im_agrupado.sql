SELECT hmd.ingreso,
CASE WHEN hm.sw_estado='1' THEN 'DESPACHADA'
     WHEN hm.sw_estado= '2' THEN 'RECIBIDA'
     ELSE 'REVISAR'
     END AS estado_solicitud,
i.tipo_id_paciente||' '||i.paciente_id as identificacion_pcte,
pa.primer_nombre||' '||pa.segundo_nombre||' '||pa.primer_apellido||' '||pa.segundo_apellido as nombre_paciente,
hm.estacion_id,
ee.descripcion as estacion_enfermeria,
hmd.medicamento_id as cod_producto,
ip.descripcion as desc_producto,
SUM(hmd.cant_solicitada) as cantidad_solicitada,
SUM(bd.cantidad) as cantidad_despachada
FROM hc_solicitudes_medicamentos_d hmd
INNER JOIN hc_solicitudes_medicamentos hm ON hmd.solicitud_id=hm.solicitud_id
INNER JOIN inventarios_productos ip ON hmd.medicamento_id=ip.codigo_producto
INNER JOIN estaciones_enfermeria ee ON hm.estacion_id=ee.estacion_id
INNER JOIN ingresos i ON hmd.ingreso=i.ingreso
INNER JOIN pacientes pa ON i.tipo_id_paciente=pa.tipo_id_paciente AND i.paciente_id=pa.paciente_id
INNER JOIN bodegas_documento_despacho_med_d bd ON hmd.consecutivo_d=bd.consecutivo_solicitud
WHERE i.fecha_ingreso::DATE BETWEEN _1 AND _2
GROUP BY 1,2,3,4,5,6,7,8