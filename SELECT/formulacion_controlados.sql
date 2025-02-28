SELECT 
  fc.formato_id AS consecutivo,
  fc.fecha_registro::date AS Fecha,
  em.razon_social as ips,
  --f.formulaelectronica,
  --em.direccion,
  --em.telefonos,
  --em.codigo_sgsss as codigo_prestador,
  --p.primer_nombre||' '||p.primer_apellido AS paciente,
  --p.tipo_id_paciente AS tipo_identificacion,
  p.paciente_id AS identificacion,
  d.tipo_diagnostico_id as Diagnostico,
   u.nombre AS Usuario_medico,
   i.descripcion AS Descripcion,
   e.cantidad,
  --i.codigo_producto AS Codigo,
  
  pr.tarjeta_profesional
  e.usuario_registro AS auxiliar_farmacia,
  
FROM
  empresas em,
  inventarios_productos i,
  hc_formulacion_medicamentos_eventos e,
  hc_formulacion_medicamentos fm,
  system_usuarios u,
  medicamentos m,
  ingresos ing,
  pacientes p,
  profesionales pr,
  hc_diagnosticos_ingreso d,
  hc_evoluciones he,
  formato_detalle fd,
  formato_cabecera fc
WHERE
  i.codigo_producto = m.codigo_medicamento
  AND m.codigo_medicamento = fm.codigo_producto
  AND fm.num_reg = e.num_reg
  AND m.sw_uso_controlado = '1'
  AND ing.ingreso = fm.ingreso
  AND ing.paciente_id = p.paciente_id
  AND ing.tipo_id_paciente = p.tipo_id_paciente
  AND ing.ingreso = he.ingreso
  AND he.evolucion_id = d.evolucion_id
  AND e.usuario_id = u.usuario_id
  AND u.usuario_id = pr.usuario_id
  AND fc.formato_id = fd.formato_id
  AND fd.ingreso = ing.ingreso
  AND fd.codigo_producto = fm.codigo_producto
  AND d.sw_principal = '1'
  -- AND fc.fecha_registro::date >= _1
  -- AND fc.fecha_registro::date <= _2
  AND fc.fecha_registro BETWEEN _1 AND _2                    
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
ORDER BY 1

