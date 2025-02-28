SELECT
c.numerodecuenta AS cuenta, pl.plan_descripcion AS entidad, p.tipo_id_paciente||' '||p.paciente_id AS paciente_id,
p.primer_nombre||' '||p.segundo_nombre||' '||p.primer_apellido||' '||p.segundo_apellido AS nombre_paciente,
bd.numeracion, bd.fecha_registro, ip.codigo_producto, ip.descripcion AS producto, bdd.cantidad,
(bdd.cantidad*inv.precio_venta)AS vlr_venta,usu.nombre as usuario_cargue
,
CASE  
WHEN bu.bodega = 'BC' THEN 'FARMACIA CIRUGIA'
WHEN bu.bodega = 'BF' THEN 'FARMACIA CENTRAL'
WHEN bu.bodega = 'OU' THEN 'FARMACIA URGENCIAS'
ELSE 'NO APLICA FARMACIA'
END AS bodega

FROM
cuentas_detalle cd
INNER JOIN cuentas c ON cd.numerodecuenta=c.numerodecuenta
INNER JOIN planes pl ON c.plan_id=pl.plan_id
INNER JOIN ingresos i ON c.ingreso=i.ingreso
INNER JOIN pacientes p ON i.tipo_id_paciente=p.tipo_id_paciente AND i.paciente_id=p.paciente_id
INNER JOIN bodegas_documentos_d bdd ON cd.consecutivo=bdd.consecutivo
INNER JOIN bodegas_documentos bd ON bdd.numeracion=bd.numeracion
INNER JOIN bodegas_doc_numeraciones bdn ON bd.bodegas_doc_id=bdn.bodegas_doc_id
INNER JOIN bodegas_usuarios bu ON cd.usuario_id=bu.usuario_id AND bdn.bodega=bu.bodega
INNER JOIN inventarios_productos ip ON bdd.codigo_producto=ip.codigo_producto
INNER JOIN inventarios inv ON ip.codigo_producto=inv.codigo_producto
INNER JOIN system_usuarios usu ON cd.usuario_id=usu.usuario_id 
WHERE bd.fecha_registro::date BETWEEN _1 AND _2
--WHERE bd.fecha_registro::date BETWEEN '2021-08-01' AND '2021-08-05'
AND cd.cargo='IMD'
--AND bdn.bodegas_doc_id IN ('85', '86')
--AND bdn.bodega='29' 
AND usu.descripcion like '%FARMACIA%'
AND NOT usu.activo= '0'
