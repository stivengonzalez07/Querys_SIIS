SELECT 
am.agenda_cita_id, 
am.tipo_id_paciente, 
am.paciente_id, 
am.tipo_consulta_id,
tc.descripcion as tipo_consulta_desc,
am.cargo,
cu.descripcion as desc_cargo,
CASE WHEN am.sw_estado= '1' THEN 'SEPARADA NO CONFIRMADA'
     WHEN am.sw_estado='2' THEN 'SEPARADA CONFIRMADA'
     WHEN am.sw_estado= '3' THEN 'ASIGNADA'
     END AS estado,
am.usuario_id,
su.nombre as usuario_asigna,
am.fecha_registro, 
am.plan_id,
p.plan_descripcion,
am.tipo_afiliado_id, 
am.rango, 
am.tipo_cita,
tt.descripcion as tipo_cita_desc,
am.fecha_cita_deseada, 
am.contador
FROM 
agenda_citas_separadas am
inner join cups cu on (am.cargo=cu.cargo)
inner join tipos_consulta tc on (am.tipo_consulta_id=tc.tipo_consulta_id)
inner join tipos_cita tt on (am.tipo_cita=tt.tipo_cita)
inner join system_usuarios su on (am.usuario_id=su.usuario_id)
inner join planes p ON (am.plan_id=p.plan_id)
where fecha_cita_deseada between '2024-08-27' and '2024-10-31'