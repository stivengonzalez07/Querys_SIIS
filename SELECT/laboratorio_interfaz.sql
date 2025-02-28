SELECT DISTINCT 
 he.ingreso,
 i.tipo_id_paciente,
 i.paciente_id,
 i.paciente_nombres ||' '|| i.paciente_apellidos as nombre_paciente,
 p.plan_descripcion,
 pa.residencia_direccion,
 pa.residencia_telefono,
 i.numero_orden_id,
 i.codigo_examen,
 i.nombre_examen,
 ho.fecha_solicitud as fecha_solicitud_examen,
 i.fecha_hora_envio as fecha_envio_interfaz,
 he.departamento,
 de.descripcion as descripcion_departamento,
 ir.fecha_resultado,
 (select ir.fecha_resultado from interface_datalab_resultados ir where i.numero_orden_id=ir.numero_orden_id limit 1) as fecha_resultado
FROM
 interface_datalab_solicitudes_i i
 INNER JOIN os_maestro om ON (i.numero_orden_id = om.numero_orden_id)
 INNER JOIN hc_os_solicitudes ho ON (om.hc_os_solicitud_id = ho.hc_os_solicitud_id)
 INNER JOIN planes p ON (ho.plan_id=p.plan_id)
 LEFT JOIN hc_evoluciones he ON (ho.evolucion_id = he.evolucion_id)
 INNER JOIN ingresos ing ON (he.ingreso=ing.ingreso)
 INNER JOIN pacientes pa ON (pa.paciente_id=ing.paciente_id)
 INNER JOIN departamentos de ON (he.departamento = de.departamento)
 LEFT JOIN interface_datalab_resultados ir ON (ir.numero_orden_id = i.numero_orden_id)
WHERE
 ho.fecha_solicitud::DATE BETWEEN _1 AND _2
ORDER BY 1,2,3,7

