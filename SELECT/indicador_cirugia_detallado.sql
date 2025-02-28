select
pac.tipo_id_paciente||' '||pac.paciente_id as identificacion_paciente,
(pac.primer_nombre||' '||pac.segundo_nombre||' '||pac.primer_apellido||' '||pac.segundo_apellido) as paciente,
plan_descripcion,
ter.nombre_tercero as profesional,
esp.descripcion as especialidad,
cu.cargo as cargo_cups,
cu.descripcion as procedimiento_programado,
qp.programacion_id,
(TO_CHAR(qqp.hora_inicio,'yyyy-mm-dd')) as fecha_programacion,
(TO_CHAR(qp.fecha_registro,'yyyy-mm-dd')) as fecha_registro_programacion,
sum((to_char(qqp.hora_inicio::date,'yyyy-mm-dd')::date-to_char(qp.fecha_registro::date,'yyyy-mm-dd')::date)) as total_dias,
(TO_CHAR(hco.hora_inicio,'yyyy-mm-dd')) as fecha_cirugia,
hco.tipo_id_cirujano||' '||hco.cirujano_id as identificacion_cirujano,
prof.nombre as cirujano,
esc.descripcion as especialidad
from qx_programaciones as qp
inner join qx_quirofanos_programacion as qqp ON qqp.programacion_id = qp.programacion_id
inner join pacientes as pac ON pac.tipo_id_paciente = qp.tipo_id_paciente and pac.paciente_id = qp.paciente_id
inner join planes as pl ON pl.plan_id = qp.plan_id
inner join terceros as ter ON ter.tipo_id_tercero = qp.tipo_id_cirujano and ter.tercero_id = qp.cirujano_id
inner join profesionales as pro ON pro.tipo_id_tercero = ter.tipo_id_tercero and pro.tercero_id = ter.tercero_id
inner join profesionales_especialidades as pe ON pe.tipo_id_tercero = pro.tipo_id_tercero and pe.tercero_id = pro.tercero_id
inner join especialidades as esp On esp.especialidad = pe.especialidad
left join qx_procedimientos_programacion as qpp ON qpp.programacion_id = qp.programacion_id
left join cups as cu ON cu.cargo = qpp.procedimiento_qx
left join hc_notas_operatorias_cirugias hco ON qp.programacion_id=hco.programacion_id
left join profesionales as prof ON prof.tercero_id = hco.cirujano_id AND hco.tipo_id_cirujano=prof.tipo_id_tercero
left join profesionales_especialidades as pre ON pre.tercero_id = prof.tercero_id AND pre.tipo_id_tercero=prof.tipo_id_tercero
left join especialidades as esc ON esc.especialidad = pre.especialidad

where qqp.qx_tipo_reserva_quirofano_id <> 0
and qqp.hora_inicio between _1 and _2
group by 1,2,3,4,5,6,7,8,9,10,12,13,14,15
order by 8