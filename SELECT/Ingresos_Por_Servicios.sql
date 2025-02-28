SELECT  i.ingreso,
--cuenta
  b.tipo_id_paciente,
  b.paciente_id,
  b.primer_nombre,
  b.segundo_nombre,
  b.primer_apellido,
  b.segundo_apellido,
  b.residencia_telefono AS telefono,
  b.residencia_direccion,
  i.fecha_ingreso,
  i.fecha_cierre,
  p.plan_descripcion,
  u.nombre as usuario_registro_ingreso,
  ab.tipo_diagnostico_id as dx_ingreso,
  ab.diagnostico_nombre as dx_ingreso_nombre,
  eb.tipo_diagnostico_id as dx_egreso,
  eb.diagnostico_nombre as dx_egreso_nombre,
  d.descripcion as departamento_ingreso,
  e.descripcion as departamento_actual,
  EXTRACT(YEAR FROM age(b.fecha_nacimiento)) AS edad,
  t.nivel_triage_id,
  pr.centro_remision,
  cr.descripcion,
  pr.fecha_remision,
  se.evento,
  sa.fecha_accidente,
  sa.sitio_accidente

           
FROM   ingresos i
INNER JOIN pacientes b ON (i.tipo_id_paciente = b.tipo_id_paciente AND i.paciente_id = b.paciente_id)
INNER JOIN (select	min(numerodecuenta) as cuenta,ingreso from cuentas where estado!='5' group by 2) ct ON (ct.ingreso=i.ingreso)
INNER JOIN cuentas c ON (ct.cuenta=c.numerodecuenta)
INNER JOIN departamentos d ON (i.departamento = d.departamento)
INNER JOIN departamentos e ON (i.departamento_actual = e.departamento)
INNER JOIN planes p ON (c.plan_id = p.plan_id)
INNER JOIN system_usuarios u ON (i.usuario_id = u.usuario_id)
LEFT JOIN (select dx.tipo_diagnostico_id, d.diagnostico_nombre, he.ingreso, dx.evolucion_id 
  from hc_diagnosticos_ingreso dx, hc_evoluciones he, diagnosticos d
  where he.evolucion_id=dx.evolucion_id and dx.tipo_diagnostico_id=d.diagnostico_id 
  and dx.sw_principal='1') as ab ON (ab.ingreso=i.ingreso)
LEFT JOIN (select dx.tipo_diagnostico_id, d.diagnostico_nombre, he.ingreso, dx.evolucion_id 
  from hc_diagnosticos_egreso dx, hc_evoluciones he, diagnosticos d
  where he.evolucion_id=dx.evolucion_id and dx.tipo_diagnostico_id=d.diagnostico_id 
  and dx.sw_principal='1') as eb ON (eb.ingreso=i.ingreso)
LEFT JOIN ingresos_soat io ON (i.ingreso=io.ingreso)
LEFT JOIN soat_eventos se ON (io.evento=se.evento)
LEFT JOIN soat_accidente sa ON (se.accidente_id=sa.accidente_id)
LEFT JOIN triages t ON (i.ingreso=t.ingreso)
LEFT JOIN pacientes_remitidos pr ON (i.ingreso=pr.ingreso)
LEFT JOIN centros_remision cr ON (pr.centro_remision=cr.centro_remision)
WHERE    i.estado<>'5'
  AND    i.fecha_ingreso::date BETWEEN _1 AND _2
  ORDER BY 1;

