SELECT 
  fc.fecha_registro::date AS Fecha,
  sm.estacion_id as servicio,
  fc.formato_id AS serie_consecutivo,
  p.paciente_id AS identificacion,
  di.diagnostico_nombre as Diagnostico,
  u.nombre AS Usuario_medico,
  i.descripcion AS Descripcion,
  e.cantidad,
  pr.tercero_id,
  e.usuario_registro AS auxiliar_farmacia
FROM 
  inventarios_productos i
 LEFT OUTER  JOIN medicamentos m on ( i.codigo_producto = m.codigo_medicamento )
 LEFT OUTER  JOIN hc_formulacion_medicamentos fm on (m.codigo_medicamento = fm.codigo_producto )
 LEFT OUTER  JOIN hc_formulacion_medicamentos_eventos e on ( fm.num_reg = e.num_reg )
 LEFT OUTER  JOIN ingresos ing on ( ing.ingreso = fm.ingreso)
 LEFT OUTER  JOIN pacientes p on (ing.paciente_id = p.paciente_id and ing.tipo_id_paciente = p.tipo_id_paciente )
 LEFT OUTER  JOIN hc_evoluciones he on (ing.ingreso = he.ingreso )
 LEFT OUTER  JOIN hc_diagnosticos_ingreso d on (he.evolucion_id = d.evolucion_id )
 LEFT OUTER  JOIN system_usuarios u on (e.usuario_id = u.usuario_id )
 LEFT OUTER  JOIN profesionales pr on ( u.usuario_id = pr.usuario_id )
 LEFT OUTER  JOIN formato_detalle fd on ( fd.ingreso = ing.ingreso)
 LEFT OUTER  JOIN formato_cabecera fc on (fd.formato_id = fc.formato_id )
 LEFT OUTER  JOIN diagnosticos di on ( di.diagnostico_id = d.tipo_diagnostico_id )
 LEFT OUTER  JOIN hc_solicitudes_medicamentos_d smd on ( he.evolucion_id = smd.evolucion_id )
 LEFT OUTER  JOIN hc_solicitudes_medicamentos sm on ( sm.solicitud_id = smd.solicitud_id )
  
WHERE
    d.sw_principal = '1'
    AND m.sw_uso_controlado = '1'
   AND fc.fecha_registro BETWEEN _1 AND _2     
  -- AND fc.fecha_registro BETWEEN '2021-09-07 08:31:09' AND '2021-09-08 10:45:16'  
   AND sm.estacion_id != 'null' 

GROUP BY fc.fecha_registro, sm.estacion_id, fc.formato_id, p.paciente_id, di.diagnostico_nombre, u.nombre, i.descripcion, e.cantidad, pr.tercero_id, 
e.usuario_registro

ORDER BY 1
