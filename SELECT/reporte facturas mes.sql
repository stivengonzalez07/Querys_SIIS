SELECT
cg.lapso,
f.prefijo,
f.factura_fiscal,
cg.total_debitos, 
cg.total_creditos,
f.saldo,
t.tipo_id_tercero,
t.tercero_id,
t.nombre_tercero

FROM 
cg_mov_01.cg_mov_contable_01 cg,
terceros t,
fac_facturas f

WHERE 
--prefijo IN('FC','FV')
f.prefijo=cg.prefijo
AND f.factura_fiscal=cg.numero
AND cg.tercero_id=t.tercero_id
AND cg.fecha_documento BETWEEN '2021-07-01' AND '2021-07-10'  --fecha solicitada