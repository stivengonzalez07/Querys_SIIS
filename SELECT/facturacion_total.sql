SELECT f.prefijo||' '||f.factura_fiscal as factura,
f.fecha_registro::date as fecha,
f.total_factura::integer,
       CASE WHEN f.estado='0' THEN 'ACTIVA'
            WHEN f.estado='1' THEN 'PAGADA'	   
            WHEN f.estado='2' THEN 'ANULADA' 
            WHEN f.estado='3' THEN 'ANULADA' 
       END AS estado,
su.nombre AS usuario_factura,
fc.numerodecuenta,
c.ingreso,
t.nombre_tercero AS tercero,
p.plan_descripcion as plan_factura,
tc.descripcion AS tipo_cliente
FROM fac_facturas f
INNER JOIN fac_facturas_cuentas fc ON f.prefijo=fc.prefijo AND f.factura_fiscal=fc.factura_fiscal
INNER JOIN cuentas c ON fc.numerodecuenta=c.numerodecuenta
INNER JOIN terceros t ON f.tipo_id_tercero=t.tipo_id_tercero AND f.tercero_id=t.tercero_id
INNER JOIN planes p ON f.plan_id=p.plan_id
INNER JOIN tipos_cliente tc ON p.tipo_cliente=tc.tipo_cliente
INNER JOIN system_usuarios su ON su.usuario_id=f.usuario_id
WHERE f.fecha_registro::DATE BETWEEN _1 AND _2