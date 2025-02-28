--REPORTE CON NIT
SELECT
g.glosa_id, g.prefijo ||' '|| g.factura_fiscal AS factura, g.prefijo_glosa ||' '|| g.numero AS documento_glosa,  
p.tipo_id_paciente ||' '|| p.paciente_id AS id_paciente,
tit.descripcion as entidad_identificacion_tipo,
pl.tercero_id as entidad_id,
pl.plan_descripcion AS entidad, 
ru.nombre AS usuario_registra,
g.fecha_glosa, 
g.fecha_registro::date, 
gtc.descripcion AS Clasificacion_Glosa, 
g.codigo_concepto_general AS cod_concepto_gral, 
gcg.descripcion_concepto_general AS concepto_general,  
g.codigo_concepto_especifico AS cod_concepto_especifico, 
gce.descripcion_concepto_especifico AS concepto_especifico, 
gre.fecha_registro AS Fecha_Registro,
gre.fecha_ratificacion,

    (SELECT rg.fecha_registro           
       FROM glosas_respuestas rg
       WHERE g.glosa_id = rg.glosa_id 
           LIMIT 1),
    (SELECT CASE WHEN rg.glosa_respuesta_id IS NOT NULL THEN 'CON RESPUESTA'
            ELSE 'SIN RESPUESTA' END AS respuesta 
            FROM glosas_respuestas rg
            WHERE g.glosa_id = rg.glosa_id 
            LIMIT 1),
    (SELECT su.nombre AS usuario_respuesta
            FROM system_usuarios su, glosas_respuestas rg
            WHERE su.usuario_id = rg.usuario_id 
            AND g.glosa_id = rg.glosa_id
            LIMIT 1), 
    (SELECT to_char(rg.fecha_registro, 'dd/mm/YYYY') as fecha_respuesta          
       FROM glosas_respuestas rg
       WHERE g.glosa_id = rg.glosa_id 
           LIMIT 1),        
    (SELECT to_char(rg.fecha_registro, 'hh24:mi:ss') as hora_respuesta          
       FROM glosas_respuestas rg
       WHERE g.glosa_id = rg.glosa_id 
           LIMIT 1),           
CASE WHEN g.sw_estado= '0' THEN 'ANULADA'
     WHEN g.sw_estado='1' THEN 'SIN RESPUESTA'
     WHEN g.sw_estado= '2' THEN 'CON RESPUESTA'
     WHEN g.sw_estado= '3' THEN 'CERRADA'
     WHEN g.sw_estado= '4' THEN 'RATIFICADA'
     END AS estado_glosa, 
ff.total_factura,
g.valor_glosa, 
SUM(gri.valor_aceptado) as valor_aceptado, 
(ff.total_factura-g.valor_aceptado)AS valor_pagar,
gre.prefijo ||' '|| gre.numero AS id_respuesta_glosa_eps, 
gre.valor_aceptado, 
gre.valor_no_aceptado
FROM
glosas g
LEFT JOIN glosas_respuestas gri ON g.glosa_id=gri.glosa_id
LEFT JOIN glosas_respuestas_eps gre ON g.glosa_id=gre.glosa_id
INNER JOIN fac_facturas ff ON ff.factura_fiscal=g.factura_fiscal AND ff.prefijo=g.prefijo
INNER JOIN fac_facturas_cuentas ffc ON ffc.factura_fiscal=ff.factura_fiscal AND ffc.prefijo=ff.prefijo
INNER JOIN cuentas c ON c.numerodecuenta=ffc.numerodecuenta
INNER JOIN planes pl ON pl.plan_id=ff.plan_id 
INNER JOIN ingresos i ON i.ingreso=c.ingreso
INNER JOIN pacientes p ON p.paciente_id=i.paciente_id AND p.tipo_id_paciente=i.tipo_id_paciente
INNER JOIN glosas_tipos_clasificacion gtc ON gtc.glosa_tipo_clasificacion_id=g.glosa_tipo_clasificacion_id
LEFT JOIN glosas_concepto_general gcg ON gcg.codigo_concepto_general=g.codigo_concepto_general
LEFT JOIN glosas_concepto_especifico gce ON gce.codigo_concepto_especifico=g.codigo_concepto_especifico
LEFT JOIN system_usuarios as ru ON g.usuario_id = ru.usuario_id
LEFT JOIN tipo_id_terceros as tit ON pl.tipo_tercero_id = tit.tipo_id_tercero
--WHERE g.fecha_glosa BETWEEN _1 AND _2
WHERE g.fecha_glosa BETWEEN '2022-03-20' AND now()

GROUP BY g.glosa_id, p.tipo_id_paciente, p.paciente_id, pl.plan_descripcion, tit.descripcion, pl.tercero_id,
ru.nombre, g.fecha_glosa, 
g.fecha_registro, 
gtc.descripcion, 
g.codigo_concepto_general, 
gcg.descripcion_concepto_general,  
g.codigo_concepto_especifico, 
gce.descripcion_concepto_especifico, ff.total_factura, gre.prefijo, gre.numero, gre.valor_aceptado, gre.valor_no_aceptado, gre.fecha_ratificacion, gre.fecha_registro
