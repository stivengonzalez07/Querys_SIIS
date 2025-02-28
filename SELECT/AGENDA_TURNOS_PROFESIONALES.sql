SELECT 
a.fecha_turno, 
a.duracion, 
a.tipo_registro,
tr.descripcion as tipo_registro_desc,
a.tipo_id_profesional, 
a.profesional_id,
p.nombre as profesional_asignado,
a.cantidad_pacientes, 
a.usuario_id,
su.nombre as usuario_asigna_agenda,
a.fecha_registro, 
a.tipo_consulta_id,
tc.descripcion,
a.agenda_turno_id
FROM 
agenda_turnos a
inner join tipos_consulta tc on (a.tipo_consulta_id=tc.tipo_consulta_id)
inner join system_usuarios su on (a.usuario_id =su.usuario_id)
inner join tipos_registro tr on (a.tipo_registro=tr.tipo_registro)
inner join profesionales p on (a.profesional_id =p.tercero_id)
where fecha_turno between '2024-08-27' and '2024-12-31'