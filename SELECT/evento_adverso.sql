
SELECT p.primer_nombre, p.segundo_nombre, p.primer_apellido, p.segundo_apellido, p.tipo_id_paciente, p.paciente_id, i.ingreso,
e.nombre_evento, e.fecha_evento, e.descripcion_evento, e.observaciones, d.descripcion as departamento
FROM pacientes p
LEFT JOIN ingresos i ON (p.paciente_id=i.paciente_id)
RIGHT JOIN hc_eventoadverso_paciente e ON (i.ingreso=e.ingreso)
LEFT JOIN hc_evoluciones h ON (e.evolucion_id=h.evolucion_id) 
LEFT JOIN departamentos d ON (h.departamento=d.departamento)
WHERE e.fecha_evento::date BETWEEN _1 AND _2
ORDER BY i.ingreso;