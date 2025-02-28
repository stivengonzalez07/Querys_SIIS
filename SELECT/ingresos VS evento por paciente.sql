select
i.paciente_id as numero_documento,
i.ingreso as ingreso_real, 
i.fecha_ingreso,
es.evento as evento_real_paciente,
se.fecha_registro as fecha_registro_evento,
s.evento as evento_soat_asociado ,

s.ingreso as ingreso_asociado,
 CASE WHEN s.evento is NULL THEN 'EVENTO NO ASOCIADO'
      WHEN s.ingreso is NULL and s.evento is NULL THEN 'INGRESO NO ASOCIADO'
      WHEN i.paciente_id != se.paciente_id THEN 'EL EVENTO NO CORRESPONDE AL PACIENTE'
      WHEN es.evento != s.evento THEN 'EL EVENTO NO ESTA ASOCIADO'

     END AS OBSERVACION 



from
ingresos_soat s 
FULL OUTER JOIN ingresos i ON (s.ingreso = i.ingreso)
FULL OUTER JOIN soat_eventos se ON (s.evento =se.evento) 
FULL OUTER JOIN soat_eventos es ON (es.paciente_id = i.paciente_id)

where
i.paciente_id ='1143845370'