SELECT  fc.*,
        CASE    WHEN e.fecha_radicacion IS NULL THEN 'SIN RADICAR'
                ELSE 'RADICADO' 
        END AS ESTADO_RADICACION, 
        e.envio_id AS nro_envio, 
        CASE    WHEN e.sw_estado='0' THEN 'ACTIVO'
                WHEN e.sw_estado='1' THEN 'RADICADO'
                WHEN e.sw_estado='2' THEN 'ANULADO'
                WHEN e.sw_estado='3' THEN 'DESPACHADO'
            ELSE 'SIN ENVIO' END AS estado_envio, 
        e.fecha_radicacion::date
FROM    (
            SELECT  c.numerodecuenta,
                    i.ingreso, 
                    de.descripcion as departamento_ingreso,
                    dea.descripcion as departamento_actual,
                    to_char(i.fecha_ingreso,'YYYY-MM-DD HH24:MI') as fecha_ingreso,
                    CASE    WHEN i.estado='0' THEN 'CERRADO'
                            WHEN i.estado='1' THEN 'ACTIVO'
                            ELSE 'LISTO PARA SALIR'
                    END AS estado_ingreso,
                    su.nombre AS usuario_admision,
                    c.fecha_registro::date AS fecha_cuenta,
                    ROUND (c.total_cuenta) AS total_cuenta,
                    c.fecha_cierre::date AS fecha_cierre,
                    pa.tipo_id_paciente,
                    pa.paciente_id,
                    pa.primer_apellido, 
                    pa.segundo_apellido, 
                    pa.primer_nombre, 
                    pa.segundo_nombre,
                    CASE    WHEN c.estado='0' THEN 'FACTURADA'
                            WHEN c.estado='1' THEN 'ACTIVA'
                            WHEN c.estado='2' THEN 'INACTIVA'
                            WHEN c.estado='3' THEN 'CUADRADA'
                            WHEN c.estado='4' THEN 'ANTICIPOS'
                            ELSE 'ANULADA' 
                    END AS cuenta_estado,
                    pl.tercero_id,
                    pl.plan_descripcion AS ENTIDAD,
                    to_char(ff.fecha_registro,'YYYY-MM-DD HH24:MI') as fecha_factura, 
                    ff.prefijo, 
                    ff.factura_fiscal as nro_factura, 
                    ff.total_factura,
                    case when ff.tipo_factura = '0' then 'PACIENTE' ELSE 'CLIENTE' END AS tipo_factura,
                    case when ff.prefijo is null then 0
                        else (
                                select sum(rcf.valor_abonado)
                                from   rc_detalle_tesoreria_facturas rcf
                                    join recibos_caja rc on (rc.empresa_id = rcf.empresa_id and rc.prefijo = rcf.prefijo and rc.recibo_caja = rcf.recibo_caja)
                                where  rcf.empresa_id = ff.empresa_id
                                and    rcf.prefijo_factura = ff.prefijo
                                and    rcf.factura_fiscal = ff.factura_fiscal
                                and    rc.estado = '2'
                            )
                    end as valor_recibos,
                    (
                        select sum(rc.total_abono)
                        from   rc_detalle_hosp rch 
                            join recibos_caja rc on (rc.empresa_id = rch.empresa_id and rc.prefijo = rch.prefijo and rc.recibo_caja = rch.recibo_caja)
                        where  rch.numerodecuenta = c.numerodecuenta
                        and    rc.estado = '0'
                    ) as recibo_caja,
                    case when ff.prefijo is null then 0
                        else (
                                select sum(ng.valor_aceptado)
                                from   glosas gl
                                    join notas_credito_glosas ng on (gl.glosa_id = ng.glosa_id)
                                where  gl.empresa_id = ff.empresa_id
                                and    gl.prefijo = ff.prefijo
                                and    gl.factura_fiscal = ff.factura_fiscal
                            )
                    end as valor_glosa_aceptado,
                    case when ff.prefijo is null then 0
                        else (
                                select sum(nc.valor_nota)
                                from   notas_credito nc
                                where  nc.empresa_id = ff.empresa_id
                                and    nc.prefijo_factura = ff.prefijo
                                and    nc.factura_fiscal = ff.factura_fiscal
                                and    nc.estado = '1'
                            )
                    end as vr_nota_credito,
                    case when ff.prefijo is null then 0
                        else (
                                select sum(nb.valor_nota)
                                from   notas_debito nb
                                where  nb.empresa_id = ff.empresa_id
                                and    nb.prefijo_factura = ff.prefijo
                                and    nb.factura_fiscal = ff.factura_fiscal
                                and    nb.estado = '1'
                            )
                    end as vr_nota_debito,
                    ff.saldo as saldo_factura,
                    CASE    WHEN ff.estado = '0' THEN 'FACTURADO'
                            WHEN ff.estado = '1' THEN 'PAGADO'
                            WHEN ff.estado = '2' THEN 'ANULADO'
                            WHEN ff.estado = '3' THEN 'ANULADA CON NOTA'
                            WHEN ff.estado IS NULL THEN 'SIN FACTURA'
                        ELSE 'SIN ESTADO'
                    END AS estado_factura,
                    to_char(isa.fecha_registro,'YYYY-MM-DD HH24:MI') as fecha_egreso,
                    case when ff.prefijo is null then 0
                        else (
                                select ed.envio_id
                                from   envios_detalle ed
                                    join envios e on (ed.envio_id = e.envio_id)
                                where  ed.empresa_id = ff.empresa_id
                                and    ed.prefijo = ff.prefijo
                                and    ed.factura_fiscal = ff.factura_fiscal
                                and    e.sw_estado != '2'
                                order by 1 desc
                                limit 1
                            )
                    end as envio_id
            FROM    ingresos i
                    left join ingresos_salidas isa on (isa.ingreso = i.ingreso)
                    join cuentas c on (i.ingreso = c.ingreso)
                    left join (
                            select  f.*,
                                    ffc.numerodecuenta
                            from    fac_facturas f
                                join    fac_facturas_cuentas ffc on (f.empresa_id = ffc.empresa_id and f.prefijo = ffc.prefijo and f.factura_fiscal = ffc.factura_fiscal)
                            where f.estado NOT IN ('2','3')
                        ) ff on (ff.numerodecuenta = c.numerodecuenta)
                    join pacientes pa on (i.tipo_id_paciente = pa.tipo_id_paciente and i.paciente_id = pa.paciente_id)
                    join departamentos de on (i.departamento = de.departamento) 
                    join departamentos dea on (i.departamento_actual = dea.departamento)
                    join system_usuarios su on (abs(c.usuario_id) = su.usuario_id)
                    join planes pl on (c.plan_id = pl.plan_id)
            WHERE   i.fecha_ingreso::date BETWEEN _1 AND _2
            AND     c.estado != '5'
            ORDER BY c.numerodecuenta
        ) fc
        left join envios e on (fc.envio_id = e.envio_id)
        ORDER BY fc.numerodecuenta

-- select
-- a.numerodecuenta,
-- a.ingreso, 
-- a.departamento,
-- a.departamento_actual,
-- a.fecha_ingreso,
-- a.estado_ingreso,
-- a.usuario_admision,
-- a.fecha_cuenta, 
-- ROUND (a.total_cuenta) AS total_cuenta, 
-- a.fecha_cierre,
-- a.primer_apellido, 
-- a.segundo_apellido, 
-- a.primer_nombre, 
-- a.segundo_nombre,
-- a.cuenta_estado,
-- a.ENTIDAD, 
-- a.tercero_id,
-- a.fecha_factura, 
-- a.prefijo, 
-- a.nro_factura, 
-- a.total_factura,
-- SUM(a.valor_recibos) as valor_recibos,
-- SUM(a.recibo_caja) AS recibo_caja,
-- SUM(a.valor_glosa_aceptado) AS valor_glosa_aceptado,
-- SUM(a.vr_nota_credito) AS vr_nota_credito,
-- SUM(a.vr_nota_debito) AS vr_nota_debito,
-- a.saldo_factura,
-- a.estado_factura, 
-- a.ESTADO_RADICACION, 
-- a.nro_envio, 
-- a.estado_envio, 
-- a.fecha_radicacion,
-- a.departamento_egreso, 
-- a.fecha_egreso, 
-- a.id_paciente

-- from (

-- SELECT 
-- c.numerodecuenta,
-- i.ingreso, 
-- i.fecha_ingreso, 

-- CASE
-- WHEN i.estado='0' THEN 'CERRADO'
-- WHEN i.estado='1' THEN 'ACTIVO'
-- ELSE 'LISTO PARA SALIR'
-- END AS estado_ingreso,
-- i.departamento,
-- i.departamento_actual,
-- su.nombre AS usuario_admision,
-- c.fecha_registro::date AS fecha_cuenta, 
-- c.total_cuenta,
-- c.fecha_cierre,
-- pc.primer_apellido, 
-- pc.segundo_apellido, 
-- pc.primer_nombre, 
-- pc.segundo_nombre,

-- CASE 
-- WHEN c.estado='0' THEN 'FACTURADA'
-- WHEN c.estado='1' THEN 'ACTIVA'
-- WHEN c.estado='2' THEN 'INACTIVA'
-- WHEN c.estado='3' THEN 'CUADRADA'
-- WHEN c.estado='4' THEN 'ANTICIPOS'
-- ELSE 'ANULADA' 
-- END AS cuenta_estado,
-- p.tercero_id,
-- p.plan_descripcion AS ENTIDAD, 
-- ff.fecha_registro::date AS fecha_factura, 
-- ff.prefijo, 
-- ff.factura_fiscal AS nro_factura, 
-- COALESCE(ff.total_factura,0) as total_factura,
-- 0 AS valor_recibos,
-- 0 AS valor_glosa_aceptado,
-- COALESCE(sum(RC.total_abono),0) AS recibo_caja,
-- COALESCE(sum(nc.valor_nota),0) AS vr_nota_credito,
-- COALESCE(sum(nd.valor_nota),0) AS vr_nota_debito,


-- CASE
-- WHEN ff.estado = '0' THEN 'FACTURADO'
-- WHEN ff.estado = '1' THEN 'PAGADO'
-- WHEN ff.estado = '2' THEN 'ANULADO'
-- WHEN ff.estado = '3' THEN 'ANULADA CON NOTA'
-- WHEN ff.estado IS NULL THEN 'SIN FACTURA'
-- ELSE 'SIN ESTADO'
-- END AS estado_factura, 

-- CASE
-- WHEN ee.fecha_radicacion IS NULL THEN 'SIN RADICAR'
-- ELSE 'RADICADO' 
-- END AS ESTADO_RADICACION, 

-- ee.envio_id AS nro_envio, 
-- CASE 
-- WHEN ee.sw_estado='1' THEN 'ACTIVO'
--      WHEN ee.sw_estado='2' THEN 'ANULADO'
--      ELSE 'SIN ENVIO' END AS estado_envio, 
     
-- ee.fecha_radicacion::date,
--  d.descripcion AS departamento_egreso, 
--  es.fecha_registro::date AS fecha_egreso, 
--  i.tipo_id_paciente||' '||i.paciente_id AS id_paciente,
-- ff.saldo as saldo_factura
--  --dx.diagnostico_nombre AS diagnostico_ingreso
 
-- FROM

-- cuentas c
-- LEFT OUTER JOIN fac_facturas_cuentas ffc ON c.numerodecuenta=ffc.numerodecuenta 
-- LEFT OUTER JOIN fac_facturas ff ON ffc.prefijo=ff.prefijo AND ffc.factura_fiscal=ff.factura_fiscal
-- --LEFT OUTER JOIN rc_detalle_tesoreria_facturas rcf ON ff.factura_fiscal=rcf.factura_fiscal AND ff.prefijo=rcf.prefijo_factura AND rcf.sw_estado='0'
-- INNER JOIN  planes p ON c.plan_id=p.plan_id 
-- LEFT OUTER JOIN ingresos i ON c.ingreso=i.ingreso
-- LEFT OUTER JOIN ingresos_salidas es ON i.ingreso=es.ingreso
-- LEFT OUTER JOIN departamentos d ON es.departamento_egreso=d.departamento
-- LEFT JOIN (
--     SELECT  ee.*,
--             ed.prefijo as prefijo_factura_envio,
--             ed.factura_fiscal as factura_fiscal_envio
--     FROM   envios ee
--     INNER JOIN envios_detalle ed on (ee.envio_id = ed.envio_id)
--     WHERE ee.sw_estado !='2'
-- ) ee ON ff.factura_fiscal=ee.factura_fiscal_envio AND ff.prefijo=ee.prefijo_factura_envio
-- /*LEFT OUTER JOIN envios_detalle ed ON ff.factura_fiscal=ed.factura_fiscal AND ff.prefijo=ed.prefijo 
-- LEFT OUTER JOIN envios ee ON ee.envio_id=ed.envio_id and ee.sw_estado !='2'
-- LEFT OUTER JOIN system_usuarios su ON c.usuario_id=su.usuario_id
-- INNER JOIN pacientes pc ON i.paciente_id=pc.paciente_id and i.tipo_id_paciente=pc.tipo_id_paciente
-- LEFT OUTER JOIN glosas g ON ff.factura_fiscal=g.factura_fiscal AND g.prefijo=ff.prefijo AND g.sw_estado != '0'
-- LEFT OUTER JOIN notas_credito nc ON ff.prefijo=nc.prefijo_factura AND ff.factura_fiscal=nc.factura_fiscal AND nc.estado='1'
-- LEFT OUTER JOIN notas_debito nd ON ff.prefijo=nd.prefijo_factura AND ff.factura_fiscal=nd.factura_fiscal AND nd.estado='1'
-- LEFT OUTER JOIN rc_detalle_hosp RCDH ON c.numerodecuenta = RCDH.numerodecuenta
-- LEFT OUTER JOIN recibos_caja RC ON RCDH.prefijo = RC.prefijo AND RCDH.recibo_caja = RC.recibo_caja

-- --
-- --LEFT OUTER JOIN hc_epicrisis_diagnosticos_ingreso hedi ON i.ingreso=hedi.ingreso
-- --LEFT OUTER JOIN diagnosticos dx ON hedi.diagnostico_id=dx.diagnostico_id

-- WHERE
-- i.fecha_ingreso::date BETWEEN _1 AND _2 
-- --ff.factura_fiscal='172' and ff.prefijo='FL'
-- GROUP BY 
-- c.numerodecuenta, i.ingreso, i.fecha_ingreso, i.estado, i.departamento,
-- i.departamento_actual, su.nombre, c.fecha_registro, c.total_cuenta, c.fecha_cierre,
-- pc.primer_apellido, pc.segundo_apellido, pc.primer_nombre, pc.segundo_nombre,
--  c.estado, p.tercero_id, p.plan_descripcion, 
-- ff.fecha_registro, ff.prefijo, ff.factura_fiscal, ff.total_factura, RC.total_abono, nc.valor_nota, nd.valor_nota,
-- ff.estado, ee.fecha_radicacion, ee.envio_id,  ee.sw_estado,
--  d.descripcion,
--  es.fecha_registro,
--  i.tipo_id_paciente,i.paciente_id,
-- ff.saldo 
-- --d.descripcion, es.fecha_registro, i.tipo_id_paciente, i.paciente_id,
-- --pc.primer_apellido, pc.segundo_apellido, pc.primer_nombre, pc.segundo_nombre, i.ingreso, i.fecha_ingreso,
-- -- g.valor_aceptado, nc.valor_nota, nd.valor_nota, p.tercero_id,ff.saldo
-- --dx.diagnostico_nombre

-- --MARLONDON
-- UNION

-- SELECT 

-- c.numerodecuenta,
-- i.ingreso, 
-- i.fecha_ingreso, 

-- CASE
-- WHEN i.estado='0' THEN 'CERRADO'
-- WHEN i.estado='1' THEN 'ACTIVO'
-- ELSE 'LISTO PARA SALIR'
-- END AS estado_ingreso,
-- i.departamento,
-- i.departamento_actual,
-- su.nombre AS usuario_admision,
-- c.fecha_registro::date AS fecha_cuenta, 
-- c.total_cuenta, c.fecha_cierre,
-- pc.primer_apellido, 
-- pc.segundo_apellido, 
-- pc.primer_nombre, 
-- pc.segundo_nombre,

-- CASE 
-- WHEN c.estado='0' THEN 'FACTURADA'
-- WHEN c.estado='1' THEN 'ACTIVA'
-- WHEN c.estado='2' THEN 'INACTIVA'
-- WHEN c.estado='3' THEN 'CUADRADA'
-- WHEN c.estado='4' THEN 'ANTICIPOS'
-- ELSE 'ANULADA' 
-- END AS cuenta_estado,
-- p.tercero_id,
-- p.plan_descripcion AS ENTIDAD, 
-- ff.fecha_registro::date AS fecha_factura, 
-- ff.prefijo, 
-- ff.factura_fiscal AS nro_factura, 
-- COALESCE(ff.total_factura,0) as total_factura,
-- 0 AS valor_recibos,
-- sum(ng.valor_aceptado) AS valor_glosa_aceptado,
-- 0 AS recibo_caja,
-- 0 AS vr_nota_credito,
-- 0 AS vr_nota_debito,


-- CASE
-- WHEN ff.estado = '0' THEN 'FACTURADO'
-- WHEN ff.estado = '1' THEN 'PAGADO'
-- WHEN ff.estado = '2' THEN 'ANULADO'
-- WHEN ff.estado = '3' THEN 'ANULADA CON NOTA'
-- WHEN ff.estado IS NULL THEN 'SIN FACTURA'
-- ELSE 'SIN ESTADO'
-- END AS estado_factura, 

-- CASE
-- WHEN ee.fecha_radicacion IS NULL THEN 'SIN RADICAR'
-- ELSE 'RADICADO' 
-- END AS ESTADO_RADICACION, 

-- ee.envio_id AS nro_envio, 
-- CASE 
-- WHEN ee.sw_estado='1' THEN 'ACTIVO'
--      WHEN ee.sw_estado='2' THEN 'ANULADO'
--      ELSE 'SIN ENVIO' END AS estado_envio, 
     
-- ee.fecha_radicacion::date,
--  d.descripcion AS departamento_egreso, 
--  es.fecha_registro::date AS fecha_egreso, 
--  i.tipo_id_paciente||' '||i.paciente_id AS id_paciente,
-- ff.saldo as saldo_factura
--  --dx.diagnostico_nombre AS diagnostico_ingreso
 
-- FROM
-- cuentas c

-- LEFT OUTER JOIN fac_facturas_cuentas ffc ON c.numerodecuenta=ffc.numerodecuenta
-- LEFT OUTER JOIN fac_facturas ff ON ffc.prefijo=ff.prefijo AND ffc.factura_fiscal=ff.factura_fiscal
-- --LEFT OUTER JOIN rc_detalle_tesoreria_facturas rcf ON ff.factura_fiscal=rcf.factura_fiscal AND ff.prefijo=rcf.prefijo_factura AND rcf.sw_estado='0'
-- INNER JOIN  planes p ON c.plan_id=p.plan_id
-- LEFT OUTER JOIN ingresos i ON c.ingreso=i.ingreso
-- LEFT OUTER JOIN ingresos_salidas es ON i.ingreso=es.ingreso
-- LEFT OUTER JOIN departamentos d ON es.departamento_egreso=d.departamento
-- LEFT JOIN (
--     SELECT  ee.*,
--             ed.prefijo as prefijo_factura_envio,
--             ed.factura_fiscal as factura_fiscal_envio
--     FROM   envios ee
--     INNER JOIN envios_detalle ed on (ee.envio_id = ed.envio_id)
--     WHERE ee.sw_estado !='2'
-- ) ee ON ff.factura_fiscal=ee.factura_fiscal_envio AND ff.prefijo=ee.prefijo_factura_envio
-- /*LEFT OUTER JOIN envios_detalle ed ON ff.factura_fiscal=ed.factura_fiscal AND ff.prefijo=ed.prefijo 
-- LEFT OUTER JOIN envios ee ON ee.envio_id=ed.envio_id*/
-- LEFT OUTER JOIN system_usuarios su ON c.usuario_id=su.usuario_id
-- INNER JOIN pacientes pc ON i.paciente_id=pc.paciente_id and i.tipo_id_paciente=pc.tipo_id_paciente
-- LEFT OUTER JOIN glosas g ON ff.factura_fiscal=g.factura_fiscal AND g.prefijo=ff.prefijo AND g.sw_estado != '0'
-- LEFT OUTER JOIN notas_credito_glosas ng ON g.glosa_id=ng.glosa_id


-- WHERE
-- i.fecha_ingreso::date BETWEEN _1 AND _2 
-- --ff.factura_fiscal='172' and ff.prefijo='FL'
-- GROUP BY 
-- c.numerodecuenta, su.nombre, c.fecha_registro, c.total_cuenta, c.estado, c.fecha_cierre, p.plan_descripcion, 
-- ff.fecha_registro, ff.prefijo, ff.factura_fiscal, ff.total_factura, ff.estado, ff.fecha_vencimiento_factura, ee.envio_id,
-- ee.sw_estado, ee.fecha_radicacion, d.descripcion, es.fecha_registro, i.tipo_id_paciente, i.paciente_id,
-- pc.primer_apellido, pc.segundo_apellido, pc.primer_nombre, pc.segundo_nombre, i.ingreso, i.fecha_ingreso, i.departamento,
-- i.departamento_actual,
--  g.valor_aceptado, p.tercero_id,ff.saldo 
-- --dx.diagnostico_nombre

-- UNION

-- SELECT 
-- c.numerodecuenta,
-- i.ingreso, 
-- i.fecha_ingreso, 
-- CASE
-- WHEN i.estado='0' THEN 'CERRADO'
-- WHEN i.estado='1' THEN 'ACTIVO'
-- ELSE 'LISTO PARA SALIR'
-- END AS estado_ingreso,
-- i.departamento,
-- i.departamento_actual,
-- su.nombre AS usuario_admision,
-- c.fecha_registro::date AS fecha_cuenta, 
-- c.total_cuenta, c.fecha_cierre,
-- pc.primer_apellido, 
-- pc.segundo_apellido, 
-- pc.primer_nombre, 
-- pc.segundo_nombre,

-- CASE 
-- WHEN c.estado='0' THEN 'FACTURADA'
-- WHEN c.estado='1' THEN 'ACTIVA'
-- WHEN c.estado='2' THEN 'INACTIVA'
-- WHEN c.estado='3' THEN 'CUADRADA'
-- WHEN c.estado='4' THEN 'ANTICIPOS'
-- ELSE 'ANULADA' 
-- END AS cuenta_estado,
-- p.tercero_id,
-- p.plan_descripcion AS ENTIDAD, 
-- ff.fecha_registro::date AS fecha_factura, 
-- ff.prefijo, 
-- ff.factura_fiscal AS nro_factura, 
-- COALESCE(ff.total_factura,0) as total_factura,
-- sum(rcf.valor_abonado) AS valor_recibos,
-- 0 AS valor_glosa_aceptado,
-- 0 AS recibo_caja,
-- 0 AS vr_nota_credito,
-- 0 AS vr_nota_debito,


-- CASE
-- WHEN ff.estado = '0' THEN 'FACTURADO'
-- WHEN ff.estado = '1' THEN 'PAGADO'
-- WHEN ff.estado = '2' THEN 'ANULADO'
-- WHEN ff.estado = '3' THEN 'ANULADA CON NOTA'
-- WHEN ff.estado IS NULL THEN 'SIN FACTURA'
-- ELSE 'SIN ESTADO'
-- END AS estado_factura, 

-- CASE
-- WHEN ee.fecha_radicacion IS NULL THEN 'SIN RADICAR'
-- ELSE 'RADICADO' 
-- END AS ESTADO_RADICACION, 

-- ee.envio_id AS nro_envio, 
-- CASE 
-- WHEN ee.sw_estado='1' THEN 'ACTIVO'
--      WHEN ee.sw_estado='2' THEN 'ANULADO'
--      ELSE 'SIN ENVIO' END AS estado_envio, 
     
-- ee.fecha_radicacion::date,
--  d.descripcion AS departamento_egreso, 
--  es.fecha_registro::date AS fecha_egreso, 
--  i.tipo_id_paciente||' '||i.paciente_id AS id_paciente,
-- ff.saldo as saldo_factura
--  --dx.diagnostico_nombre
 
-- FROM
-- cuentas c

-- LEFT OUTER JOIN fac_facturas_cuentas ffc ON c.numerodecuenta=ffc.numerodecuenta
-- LEFT OUTER JOIN fac_facturas ff ON ffc.factura_fiscal=ff.factura_fiscal AND ffc.prefijo=ff.prefijo
-- LEFT OUTER JOIN rc_detalle_tesoreria_facturas rcf ON ff.factura_fiscal=rcf.factura_fiscal 
--                                                 AND ff.prefijo=rcf.prefijo_factura AND rcf.sw_estado='0'
-- INNER JOIN  planes p ON c.plan_id=p.plan_id
-- LEFT OUTER JOIN ingresos i ON c.ingreso=i.ingreso
-- LEFT OUTER JOIN ingresos_salidas es ON i.ingreso=es.ingreso
-- LEFT OUTER JOIN departamentos d ON es.departamento_egreso=d.departamento
-- LEFT JOIN (
--     SELECT  ee.*,
--             ed.prefijo as prefijo_factura_envio,
--             ed.factura_fiscal as factura_fiscal_envio
--     FROM   envios ee
--     INNER JOIN envios_detalle ed on (ee.envio_id = ed.envio_id)
--     WHERE ee.sw_estado !='2'
-- ) ee ON ff.factura_fiscal=ee.factura_fiscal_envio AND ff.prefijo=ee.prefijo_factura_envio
-- /*LEFT OUTER JOIN envios_detalle ed ON ff.factura_fiscal=ed.factura_fiscal AND ff.prefijo=ed.prefijo 
-- LEFT OUTER JOIN envios ee ON ee.envio_id=ed.envio_id*/
-- LEFT OUTER JOIN system_usuarios su ON c.usuario_id=su.usuario_id
-- INNER JOIN pacientes pc ON i.paciente_id=pc.paciente_id and i.tipo_id_paciente=pc.tipo_id_paciente


-- --
-- --LEFT OUTER JOIN hc_epicrisis_diagnosticos_ingreso hedi ON i.ingreso=hedi.ingreso
-- --LEFT OUTER JOIN diagnosticos dx ON hedi.diagnostico_id=dx.diagnostico_id




-- WHERE
-- i.fecha_ingreso::date BETWEEN _1 AND _2 
-- --ff.factura_fiscal='172' and ff.prefijo='FL'

-- GROUP BY 
-- c.numerodecuenta, su.nombre, c.fecha_registro, c.total_cuenta, c.estado, c.fecha_cierre, p.plan_descripcion, 
-- ff.fecha_registro, ff.prefijo, ff.factura_fiscal, ff.total_factura, ff.estado, ff.fecha_vencimiento_factura, ee.envio_id,
-- ee.sw_estado, ee.fecha_radicacion, d.descripcion, es.fecha_registro, i.tipo_id_paciente, i.paciente_id,
-- pc.primer_apellido, pc.segundo_apellido, pc.primer_nombre, pc.segundo_nombre, i.ingreso, i.departamento,
-- i.departamento_actual, i.fecha_ingreso, p.tercero_id,ff.saldo
-- --dx.diagnostico_nombre
-- ) a
-- GROUP BY a.numerodecuenta,
-- a.ingreso, 
-- a.departamento,
-- a.departamento_actual,
-- a.fecha_ingreso, 
-- a.estado_ingreso,
-- a.usuario_admision,
-- a.fecha_cuenta, 
-- a.total_cuenta, a.fecha_cierre,
-- a.primer_apellido, 
-- a.segundo_apellido, 
-- a.primer_nombre, 
-- a.segundo_nombre,
-- a.cuenta_estado,
-- a.ENTIDAD, 
-- a.fecha_factura, 
-- a.prefijo, 
-- a.nro_factura, 
-- a.total_factura,
-- a.estado_factura, 
-- a.ESTADO_RADICACION, 
-- a.nro_envio, 
-- a.estado_envio, 
-- a.fecha_radicacion,
-- a.departamento_egreso, 
-- a.fecha_egreso, 
-- a.id_paciente,
-- a.tercero_id,
-- a.saldo_factura
-- /*select
-- a.numerodecuenta,
-- a.ingreso, 
-- a.departamento,
-- a.departamento_actual,
-- a.fecha_ingreso,
-- a.estado_ingreso,
-- a.usuario_admision,
-- a.fecha_cuenta, 
-- ROUND (a.total_cuenta) AS total_cuenta, 
-- a.fecha_cierre,
-- a.primer_apellido, 
-- a.segundo_apellido, 
-- a.primer_nombre, 
-- a.segundo_nombre,
-- a.cuenta_estado,
-- a.ENTIDAD, 
-- a.tercero_id,
-- a.fecha_factura, 
-- a.prefijo, 
-- a.nro_factura, 
-- a.total_factura,
-- SUM(a.valor_recibos) as valor_recibos,
-- SUM(a.recibo_caja) AS recibo_caja,
-- SUM(a.valor_glosa_aceptado) AS valor_glosa_aceptado,
-- SUM(a.vr_nota_credito) AS vr_nota_credito,
-- SUM(a.vr_nota_debito) AS vr_nota_debito,
-- a.saldo_factura,
-- a.estado_factura, 
-- a.ESTADO_RADICACION, 
-- a.nro_envio, 
-- a.estado_envio, 
-- a.fecha_radicacion,
-- a.departamento_egreso, 
-- a.fecha_egreso, 
-- a.id_paciente

-- from (

-- SELECT 
-- c.numerodecuenta,
-- i.ingreso, 
-- i.fecha_ingreso, 

-- CASE
-- WHEN i.estado='0' THEN 'CERRADO'
-- WHEN i.estado='1' THEN 'ACTIVO'
-- ELSE 'LISTO PARA SALIR'
-- END AS estado_ingreso,
-- i.departamento,
-- i.departamento_actual,
-- su.nombre AS usuario_admision,
-- c.fecha_registro::date AS fecha_cuenta, 
-- c.total_cuenta,
-- c.fecha_cierre,
-- pc.primer_apellido, 
-- pc.segundo_apellido, 
-- pc.primer_nombre, 
-- pc.segundo_nombre,

-- CASE 
-- WHEN c.estado='0' THEN 'FACTURADA'
-- WHEN c.estado='1' THEN 'ACTIVA'
-- WHEN c.estado='2' THEN 'INACTIVA'
-- WHEN c.estado='3' THEN 'CUADRADA'
-- WHEN c.estado='4' THEN 'ANTICIPOS'
-- ELSE 'ANULADA' 
-- END AS cuenta_estado,
-- p.tercero_id,
-- p.plan_descripcion AS ENTIDAD, 
-- ff.fecha_registro::date AS fecha_factura, 
-- ff.prefijo, 
-- ff.factura_fiscal AS nro_factura, 
-- COALESCE(ff.total_factura,0) as total_factura,
-- 0 AS valor_recibos,
-- 0 AS valor_glosa_aceptado,
-- COALESCE(sum(RC.total_abono),0) AS recibo_caja,
-- COALESCE(sum(nc.valor_nota),0) AS vr_nota_credito,
-- COALESCE(sum(nd.valor_nota),0) AS vr_nota_debito,


-- CASE
-- WHEN ff.estado = '0' THEN 'FACTURADO'
-- WHEN ff.estado = '1' THEN 'PAGADO'
-- WHEN ff.estado = '2' THEN 'ANULADO'
-- WHEN ff.estado = '3' THEN 'ANULADA CON NOTA'
-- WHEN ff.estado IS NULL THEN 'SIN FACTURA'
-- ELSE 'SIN ESTADO'
-- END AS estado_factura, 

-- CASE
-- WHEN ee.fecha_radicacion IS NULL THEN 'SIN RADICAR'
-- ELSE 'RADICADO' 
-- END AS ESTADO_RADICACION, 

-- ee.envio_id AS nro_envio, 
-- CASE 
-- WHEN ee.sw_estado='1' THEN 'ACTIVO'
--      WHEN ee.sw_estado='2' THEN 'ANULADO'
--      ELSE 'SIN ENVIO' END AS estado_envio, 
	 
-- ee.fecha_radicacion::date,
--  d.descripcion AS departamento_egreso, 
--  es.fecha_registro::date AS fecha_egreso, 
--  i.tipo_id_paciente||' '||i.paciente_id AS id_paciente,
-- ff.saldo as saldo_factura
--  --dx.diagnostico_nombre AS diagnostico_ingreso
 
-- FROM

-- cuentas c
-- LEFT OUTER JOIN fac_facturas_cuentas ffc ON c.numerodecuenta=ffc.numerodecuenta 
-- LEFT OUTER JOIN fac_facturas ff ON ffc.prefijo=ff.prefijo AND ffc.factura_fiscal=ff.factura_fiscal
-- --LEFT OUTER JOIN rc_detalle_tesoreria_facturas rcf ON ff.factura_fiscal=rcf.factura_fiscal AND ff.prefijo=rcf.prefijo_factura AND rcf.sw_estado='0'
-- INNER JOIN  planes p ON c.plan_id=p.plan_id 
-- LEFT OUTER JOIN ingresos i ON c.ingreso=i.ingreso
-- LEFT OUTER JOIN ingresos_salidas es ON i.ingreso=es.ingreso
-- LEFT OUTER JOIN departamentos d ON es.departamento_egreso=d.departamento
-- LEFT OUTER JOIN envios_detalle ed ON ff.factura_fiscal=ed.factura_fiscal AND ff.prefijo=ed.prefijo 
-- LEFT OUTER JOIN envios ee ON ee.envio_id=ed.envio_id and ee.sw_estado !='2'
-- LEFT OUTER JOIN system_usuarios su ON c.usuario_id=su.usuario_id
-- INNER JOIN pacientes pc ON i.paciente_id=pc.paciente_id and i.tipo_id_paciente=pc.tipo_id_paciente
-- LEFT OUTER JOIN glosas g ON ff.factura_fiscal=g.factura_fiscal AND g.prefijo=ff.prefijo AND g.sw_estado != '0'
-- LEFT OUTER JOIN notas_credito nc ON ff.prefijo=nc.prefijo_factura AND ff.factura_fiscal=nc.factura_fiscal AND nc.estado='1'
-- LEFT OUTER JOIN notas_debito nd ON ff.prefijo=nd.prefijo_factura AND ff.factura_fiscal=nd.factura_fiscal AND nd.estado='1'
-- LEFT OUTER JOIN rc_detalle_hosp RCDH ON c.numerodecuenta = RCDH.numerodecuenta
-- LEFT OUTER JOIN recibos_caja RC ON RCDH.prefijo = RC.prefijo AND RCDH.recibo_caja = RC.recibo_caja

-- --
-- --LEFT OUTER JOIN hc_epicrisis_diagnosticos_ingreso hedi ON i.ingreso=hedi.ingreso
-- --LEFT OUTER JOIN diagnosticos dx ON hedi.diagnostico_id=dx.diagnostico_id

-- WHERE
-- c.fecha_registro::date BETWEEN _1 AND _2 
-- --ff.factura_fiscal='2245' and ff.prefijo='FC'
-- GROUP BY 
-- c.numerodecuenta, i.ingreso, i.fecha_ingreso, i.estado, i.departamento,
-- i.departamento_actual, su.nombre, c.fecha_registro, c.total_cuenta, c.fecha_cierre,
-- pc.primer_apellido, pc.segundo_apellido, pc.primer_nombre, pc.segundo_nombre,
--  c.estado, p.tercero_id, p.plan_descripcion, 
-- ff.fecha_registro, ff.prefijo, ff.factura_fiscal, ff.total_factura, RC.total_abono, nc.valor_nota, nd.valor_nota,
-- ff.estado, ee.fecha_radicacion, ee.envio_id,  ee.sw_estado,
--  d.descripcion,
--  es.fecha_registro,
--  i.tipo_id_paciente,i.paciente_id,
-- ff.saldo 
-- --d.descripcion, es.fecha_registro, i.tipo_id_paciente, i.paciente_id,
-- --pc.primer_apellido, pc.segundo_apellido, pc.primer_nombre, pc.segundo_nombre, i.ingreso, i.fecha_ingreso,
-- -- g.valor_aceptado, nc.valor_nota, nd.valor_nota, p.tercero_id,ff.saldo
-- --dx.diagnostico_nombre

-- --MARLONDON
-- UNION

-- SELECT 

-- c.numerodecuenta,
-- i.ingreso, 
-- i.fecha_ingreso, 

-- CASE
-- WHEN i.estado='0' THEN 'CERRADO'
-- WHEN i.estado='1' THEN 'ACTIVO'
-- ELSE 'LISTO PARA SALIR'
-- END AS estado_ingreso,
-- i.departamento,
-- i.departamento_actual,
-- su.nombre AS usuario_admision,
-- c.fecha_registro::date AS fecha_cuenta, 
-- c.total_cuenta, c.fecha_cierre,
-- pc.primer_apellido, 
-- pc.segundo_apellido, 
-- pc.primer_nombre, 
-- pc.segundo_nombre,

-- CASE 
-- WHEN c.estado='0' THEN 'FACTURADA'
-- WHEN c.estado='1' THEN 'ACTIVA'
-- WHEN c.estado='2' THEN 'INACTIVA'
-- WHEN c.estado='3' THEN 'CUADRADA'
-- WHEN c.estado='4' THEN 'ANTICIPOS'
-- ELSE 'ANULADA' 
-- END AS cuenta_estado,
-- p.tercero_id,
-- p.plan_descripcion AS ENTIDAD, 
-- ff.fecha_registro::date AS fecha_factura, 
-- ff.prefijo, 
-- ff.factura_fiscal AS nro_factura, 
-- COALESCE(ff.total_factura,0) as total_factura,
-- 0 AS valor_recibos,
-- sum(ng.valor_aceptado) AS valor_glosa_aceptado,
-- 0 AS recibo_caja,
-- 0 AS vr_nota_credito,
-- 0 AS vr_nota_debito,


-- CASE
-- WHEN ff.estado = '0' THEN 'FACTURADO'
-- WHEN ff.estado = '1' THEN 'PAGADO'
-- WHEN ff.estado = '2' THEN 'ANULADO'
-- WHEN ff.estado = '3' THEN 'ANULADA CON NOTA'
-- WHEN ff.estado IS NULL THEN 'SIN FACTURA'
-- ELSE 'SIN ESTADO'
-- END AS estado_factura, 

-- CASE
-- WHEN ee.fecha_radicacion IS NULL THEN 'SIN RADICAR'
-- ELSE 'RADICADO' 
-- END AS ESTADO_RADICACION, 

-- ee.envio_id AS nro_envio, 
-- CASE 
-- WHEN ee.sw_estado='1' THEN 'ACTIVO'
--      WHEN ee.sw_estado='2' THEN 'ANULADO'
--      ELSE 'SIN ENVIO' END AS estado_envio, 
	 
-- ee.fecha_radicacion::date,
--  d.descripcion AS departamento_egreso, 
--  es.fecha_registro::date AS fecha_egreso, 
--  i.tipo_id_paciente||' '||i.paciente_id AS id_paciente,
-- ff.saldo as saldo_factura
--  --dx.diagnostico_nombre AS diagnostico_ingreso
 
-- FROM
-- cuentas c

-- LEFT OUTER JOIN fac_facturas_cuentas ffc ON c.numerodecuenta=ffc.numerodecuenta
-- LEFT OUTER JOIN fac_facturas ff ON ffc.prefijo=ff.prefijo AND ffc.factura_fiscal=ff.factura_fiscal
-- --LEFT OUTER JOIN rc_detalle_tesoreria_facturas rcf ON ff.factura_fiscal=rcf.factura_fiscal AND ff.prefijo=rcf.prefijo_factura AND rcf.sw_estado='0'
-- INNER JOIN  planes p ON c.plan_id=p.plan_id
-- LEFT OUTER JOIN ingresos i ON c.ingreso=i.ingreso
-- LEFT OUTER JOIN ingresos_salidas es ON i.ingreso=es.ingreso
-- LEFT OUTER JOIN departamentos d ON es.departamento_egreso=d.departamento
-- LEFT OUTER JOIN envios_detalle ed ON ff.factura_fiscal=ed.factura_fiscal AND ff.prefijo=ed.prefijo 
-- LEFT OUTER JOIN envios ee ON ee.envio_id=ed.envio_id
-- LEFT OUTER JOIN system_usuarios su ON c.usuario_id=su.usuario_id
-- INNER JOIN pacientes pc ON i.paciente_id=pc.paciente_id and i.tipo_id_paciente=pc.tipo_id_paciente
-- LEFT OUTER JOIN glosas g ON ff.factura_fiscal=g.factura_fiscal AND g.prefijo=ff.prefijo AND g.sw_estado != '0'
-- LEFT OUTER JOIN notas_credito_glosas ng ON g.glosa_id=ng.glosa_id


-- WHERE
-- c.fecha_registro::date BETWEEN _1 AND _2 
-- --ff.factura_fiscal='2245' and ff.prefijo='FC'
-- GROUP BY 
-- c.numerodecuenta, su.nombre, c.fecha_registro, c.total_cuenta, c.estado, c.fecha_cierre, p.plan_descripcion, 
-- ff.fecha_registro, ff.prefijo, ff.factura_fiscal, ff.total_factura, ff.estado, ff.fecha_vencimiento_factura, ee.envio_id,
-- ee.sw_estado, ee.fecha_radicacion, d.descripcion, es.fecha_registro, i.tipo_id_paciente, i.paciente_id,
-- pc.primer_apellido, pc.segundo_apellido, pc.primer_nombre, pc.segundo_nombre, i.ingreso, i.fecha_ingreso, i.departamento,
-- i.departamento_actual,
--  g.valor_aceptado, p.tercero_id,ff.saldo 
-- --dx.diagnostico_nombre

-- UNION

-- SELECT 
-- c.numerodecuenta,
-- i.ingreso, 
-- i.fecha_ingreso, 
-- CASE
-- WHEN i.estado='0' THEN 'CERRADO'
-- WHEN i.estado='1' THEN 'ACTIVO'
-- ELSE 'LISTO PARA SALIR'
-- END AS estado_ingreso,
-- i.departamento,
-- i.departamento_actual,
-- su.nombre AS usuario_admision,
-- c.fecha_registro::date AS fecha_cuenta, 
-- c.total_cuenta, c.fecha_cierre,
-- pc.primer_apellido, 
-- pc.segundo_apellido, 
-- pc.primer_nombre, 
-- pc.segundo_nombre,

-- CASE 
-- WHEN c.estado='0' THEN 'FACTURADA'
-- WHEN c.estado='1' THEN 'ACTIVA'
-- WHEN c.estado='2' THEN 'INACTIVA'
-- WHEN c.estado='3' THEN 'CUADRADA'
-- WHEN c.estado='4' THEN 'ANTICIPOS'
-- ELSE 'ANULADA' 
-- END AS cuenta_estado,
-- p.tercero_id,
-- p.plan_descripcion AS ENTIDAD, 
-- ff.fecha_registro::date AS fecha_factura, 
-- ff.prefijo, 
-- ff.factura_fiscal AS nro_factura, 
-- COALESCE(ff.total_factura,0) as total_factura,
-- sum(rcf.valor_abonado) AS valor_recibos,
-- 0 AS valor_glosa_aceptado,
-- 0 AS recibo_caja,
-- 0 AS vr_nota_credito,
-- 0 AS vr_nota_debito,


-- CASE
-- WHEN ff.estado = '0' THEN 'FACTURADO'
-- WHEN ff.estado = '1' THEN 'PAGADO'
-- WHEN ff.estado = '2' THEN 'ANULADO'
-- WHEN ff.estado = '3' THEN 'ANULADA CON NOTA'
-- WHEN ff.estado IS NULL THEN 'SIN FACTURA'
-- ELSE 'SIN ESTADO'
-- END AS estado_factura, 

-- CASE
-- WHEN ee.fecha_radicacion IS NULL THEN 'SIN RADICAR'
-- ELSE 'RADICADO' 
-- END AS ESTADO_RADICACION, 

-- ee.envio_id AS nro_envio, 
-- CASE 
-- WHEN ee.sw_estado='1' THEN 'ACTIVO'
--      WHEN ee.sw_estado='2' THEN 'ANULADO'
--      ELSE 'SIN ENVIO' END AS estado_envio, 
	 
-- ee.fecha_radicacion::date,
--  d.descripcion AS departamento_egreso, 
--  es.fecha_registro::date AS fecha_egreso, 
--  i.tipo_id_paciente||' '||i.paciente_id AS id_paciente,
-- ff.saldo as saldo_factura
--  --dx.diagnostico_nombre
 
-- FROM
-- cuentas c

-- LEFT OUTER JOIN fac_facturas_cuentas ffc ON c.numerodecuenta=ffc.numerodecuenta
-- LEFT OUTER JOIN fac_facturas ff ON ffc.factura_fiscal=ff.factura_fiscal AND ffc.prefijo=ff.prefijo
-- LEFT OUTER JOIN rc_detalle_tesoreria_facturas rcf ON ff.factura_fiscal=rcf.factura_fiscal 
-- 												AND ff.prefijo=rcf.prefijo_factura AND rcf.sw_estado='0'
-- INNER JOIN  planes p ON c.plan_id=p.plan_id
-- LEFT OUTER JOIN ingresos i ON c.ingreso=i.ingreso
-- LEFT OUTER JOIN ingresos_salidas es ON i.ingreso=es.ingreso
-- LEFT OUTER JOIN departamentos d ON es.departamento_egreso=d.departamento
-- LEFT OUTER JOIN envios_detalle ed ON ff.factura_fiscal=ed.factura_fiscal AND ff.prefijo=ed.prefijo 
-- LEFT OUTER JOIN envios ee ON ee.envio_id=ed.envio_id
-- LEFT OUTER JOIN system_usuarios su ON c.usuario_id=su.usuario_id
-- INNER JOIN pacientes pc ON i.paciente_id=pc.paciente_id and i.tipo_id_paciente=pc.tipo_id_paciente


-- --
-- --LEFT OUTER JOIN hc_epicrisis_diagnosticos_ingreso hedi ON i.ingreso=hedi.ingreso
-- --LEFT OUTER JOIN diagnosticos dx ON hedi.diagnostico_id=dx.diagnostico_id




-- WHERE
-- c.fecha_registro::date BETWEEN _1 AND _2 
-- --ff.factura_fiscal='2245' and ff.prefijo='FC'

-- GROUP BY 
-- c.numerodecuenta, su.nombre, c.fecha_registro, c.total_cuenta, c.estado, c.fecha_cierre, p.plan_descripcion, 
-- ff.fecha_registro, ff.prefijo, ff.factura_fiscal, ff.total_factura, ff.estado, ff.fecha_vencimiento_factura, ee.envio_id,
-- ee.sw_estado, ee.fecha_radicacion, d.descripcion, es.fecha_registro, i.tipo_id_paciente, i.paciente_id,
-- pc.primer_apellido, pc.segundo_apellido, pc.primer_nombre, pc.segundo_nombre, i.ingreso, i.departamento,
-- i.departamento_actual, i.fecha_ingreso, p.tercero_id,ff.saldo
-- --dx.diagnostico_nombre
-- ) a
-- GROUP BY a.numerodecuenta,
-- a.ingreso, 
-- a.departamento,
-- a.departamento_actual,
-- a.fecha_ingreso, 
-- a.estado_ingreso,
-- a.usuario_admision,
-- a.fecha_cuenta, 
-- a.total_cuenta, a.fecha_cierre,
-- a.primer_apellido, 
-- a.segundo_apellido, 
-- a.primer_nombre, 
-- a.segundo_nombre,
-- a.cuenta_estado,
-- a.ENTIDAD, 
-- a.fecha_factura, 
-- a.prefijo, 
-- a.nro_factura, 
-- a.total_factura,
-- a.estado_factura, 
-- a.ESTADO_RADICACION, 
-- a.nro_envio, 
-- a.estado_envio, 
-- a.fecha_radicacion,
-- a.departamento_egreso, 
-- a.fecha_egreso, 
-- a.id_paciente,
-- a.tercero_id,
-- a.saldo_factura*/
-- */
