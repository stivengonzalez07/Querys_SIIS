SELECT 
  fc.fecha_registro::date AS Fecha,
  sm.estacion_id as servicio,
  fc.formato_id AS serie_consecutivo,
  p.paciente_id AS identificacion,
  di.diagnostico_nombre as Diagnostico,
  pr.nombre AS Usuario_medico,
  i.descripcion AS Descripcion,
  e.cantidad,
  pr.tercero_id,
  u.nombre AS axiliar_farmacia
FROM 
  inventarios_productos i
 LEFT OUTER  JOIN medicamentos m on ( i.codigo_producto = m.codigo_medicamento )
 LEFT OUTER  JOIN hc_formulacion_medicamentos fm on (m.codigo_medicamento = fm.codigo_producto )
 LEFT OUTER  JOIN hc_formulacion_medicamentos_eventos e on ( fm.num_reg = e.num_reg )
 LEFT OUTER  JOIN ingresos ing on (ing.ingreso = fm.ingreso)
 LEFT OUTER  JOIN pacientes p on (ing.paciente_id = p.paciente_id and ing.tipo_id_paciente = p.tipo_id_paciente )
 LEFT OUTER  JOIN hc_evoluciones he on (ing.ingreso = he.ingreso )
 LEFT OUTER  JOIN hc_diagnosticos_ingreso d on (he.evolucion_id = d.evolucion_id )
 LEFT OUTER  JOIN profesionales pr on (e.usuario_id = pr.usuario_id )
 LEFT OUTER  JOIN formato_detalle fd on ( fd.ingreso = ing.ingreso)
 LEFT OUTER  JOIN formato_cabecera fc on (fd.formato_id = fc.formato_id )
 LEFT OUTER  JOIN diagnosticos di on ( di.diagnostico_id = d.tipo_diagnostico_id )
 LEFT OUTER  JOIN hc_solicitudes_medicamentos_d smd on ( he.evolucion_id = smd.evolucion_id )
 LEFT OUTER  JOIN hc_solicitudes_medicamentos sm on ( sm.solicitud_id = smd.solicitud_id )
 --LO ANADIDO
 INNER JOIN bodegas_documento_despacho_med_d ddmd on ( smd.consecutivo_d = ddmd.consecutivo_solicitud ) 

 INNER JOIN bodegas_documento_despacho_med ddm on ( ddm.documento_despacho_id = ddmd.documento_despacho_id ) 
--LO ANADIDO
 LEFT OUTER  JOIN system_usuarios u on (u.usuario_id = ddm.usuario_id )
WHERE d.sw_principal = '1'
   AND m.sw_uso_controlado = '1'
   --AND fc.fecha_registro BETWEEN _1 AND _2     
   AND fc.fecha_registro BETWEEN '2021-11-01' AND '2021-11-30'  
   AND sm.estacion_id != 'null' 

GROUP BY fc.fecha_registro, sm.estacion_id, fc.formato_id, p.paciente_id, di.diagnostico_nombre, pr.nombre, i.descripcion, e.cantidad, pr.tercero_id, 
u.nombre 

ORDER BY 1
