SELECT cl.fecha_cirugia::date,i.tipo_id_paciente, i.paciente_id, 
p.primer_nombre, p.segundo_nombre, p.primer_apellido, p.segundo_apellido, 
p.fecha_nacimiento,
edad(p.fecha_nacimiento) as edad,
c.descripcion as cargo,
a.descripcion as ambito
FROM ingresos i,pacientes p,qx_ambitos_cirugias a,cuentas_liquidaciones_qx cl,cups c
WHERE i.tipo_id_paciente=p.tipo_id_paciente
AND i.paciente_id=p.paciente_id
AND i.ingreso=cl.ingreso
AND cl.estado!='3'
AND cl.ambito_cirugia_id=a.ambito_cirugia_id
AND cl.cargo_principal=c.cargo
AND cl.fecha_cirugia::date>=_1
AND cl.fecha_cirugia::date<=_2
ORDER BY 1