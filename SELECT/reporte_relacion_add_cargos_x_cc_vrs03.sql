SELECT  cta_ff.fecha_registro as fecha_factura,
        cta_ff.prefijo||' '||cta_ff.factura_fiscal as factura,
        cu.numerodecuenta,
        pl.plan_descripcion,
        su.nombre as usuario,
        dp.departamento as cod_departamento,
        dp.descripcion as departamento_desc,
        cd.cargo_cups as cargo,
        cux.descripcion as desc_cargo,
        ccp.departamento AS departamento,
        case    when a.cuenta is not null then a.cuenta
                when a.cuenta is null then (select xx.cuenta from cg_conf.doc_fv01_cups_por_cc xx where cd.empresa_id = xx.empresa_id and cd.cargo_cups = xx.cargo limit 1)
                when b.cuenta is not null then b.cuenta
                when c.cuenta is not null then c.cuenta
                when d.cuenta is not null then d.cuenta
                when e.cuenta is not null then e.cuenta
            else 'Sin Parametrizacion'
        end as cuenta,
        case    when a.cuenta is not null then a.centro_costo_destino
                when a.cuenta is null then (select xx.centro_costo_destino from cg_conf.doc_fv01_cups_por_cc xx where cd.empresa_id = xx.empresa_id and cd.cargo_cups = xx.cargo limit 1)
                when b.cuenta is not null then b.centro_costo_destino
                when c.cuenta is not null then ccp.centro_de_costo_id
                when d.cuenta is not null then d.centro_costo_destino
                when e.cuenta is not null then ccp.centro_de_costo_id
            else 'Sin Parametrizacion'
        end as centro_costo,
        case when cu.estado = '0' then 'FACTURADO'
            else 'CARGADO'
        end as estado_cuenta,
        cd.valor_cargo,
        cd.cantidad
FROM    cuentas_detalle cd
        join departamentos dp on (cd.departamento = dp.departamento)
        join (
                SELECT  DISTINCT ON (ffc.numerodecuenta) numerodecuenta,
                        ff.prefijo,
                        ff.factura_fiscal,
                        ff.fecha_registro as fecha_registro
                FROM    fac_facturas ff 
                        join fac_facturas_cuentas ffc 
                        on (ffc.empresa_id = ff.empresa_id and ffc.prefijo = ff.prefijo and ffc.factura_fiscal = ff.factura_fiscal)
                WHERE   ff.fecha_registro::date >= _1
                AND     ff.fecha_registro::date <= _2
                AND     ff.estado NOT IN ('2','3')
                ORDER BY ffc.numerodecuenta, ff.fecha_registro desc
            ) as cta_ff on (cd.numerodecuenta = cta_ff.numerodecuenta)
        join system_usuarios su on (cd.usuario_id = su.usuario_id)
        join tarifarios_detalle td on (cd.tarifario_id = td.tarifario_id and cd.cargo = td.cargo)
        join cups cux on (cd.cargo_cups = cux.cargo)
        join cuentas cu on (cd.numerodecuenta = cu.numerodecuenta)
        join planes pl on (pl.plan_id = cu.plan_id)
        join cg_conf.centros_de_costo_departamentos ccp on (cd.departamento = ccp.departamento)
        left join cg_conf.doc_fv01_cups_por_cc a on (cd.empresa_id = a.empresa_id and cd.cargo_cups = a.cargo and cd.departamento = a.departamento)
        left join cg_conf.doc_fv01_cargos_por_cc b on (cd.empresa_id = b.empresa_id and cd.tarifario_id = b.tarifario_id and cd.cargo = b.cargo and ccp.centro_de_costo_id = b.centro_de_costo_id)
        left join cg_conf.doc_fv01_cargos c on (cd.empresa_id = c.empresa_id and cd.tarifario_id = c.tarifario_id and cd.cargo = c.cargo)
        left join cg_conf.doc_fv01_grupos_cargos_por_cc d on (cd.empresa_id = d.empresa_id and td.grupo_tarifario_id = d.grupo_tarifario_id and td.subgrupo_tarifario_id = d.subgrupo_tarifario_id and ccp.centro_de_costo_id = d.centro_de_costo_id)
        left join cg_conf.doc_fv01_grupos_cargos e on (cd.empresa_id = e.empresa_id and td.grupo_tarifario_id = e.grupo_tarifario_id and td.subgrupo_tarifario_id = e.subgrupo_tarifario_id)
WHERE   ((cd.paquete_codigo_id IS NULL AND cd.facturado = '1') OR (cd.paquete_codigo_id IS NOT NULL AND cd.sw_paquete_facturado = '1'))
AND     cu.estado != '5'
UNION ALL
SELECT  cta_ff.fecha_registro as fecha_cargo,
        cta_ff.prefijo||' '||cta_ff.factura_fiscal as factura,
        cu.numerodecuenta,
        pl.plan_descripcion,
        su.nombre as usuario,
        dp.departamento as cod_departamento,
        dp.descripcion as departamento_desc,
        ip.codigo_producto as cargo,
        ip.descripcion as desc_cargo,
        ccp.departamento AS departamento,
        case    when a.cuenta is not null then a.cuenta
                when b.cuenta is not null then b.cuenta
                when c.cuenta is not null then c.cuenta
                when d.cuenta is not null then d.cuenta
                when a.cuenta is null then (select xx.cuenta from cg_conf.doc_fv01_inv_grupos_productos_por_cc xx where cd.empresa_id = xx.empresa_id and ip.grupo_id = xx.grupo_id and ip.clase_id = xx.clase_id and ip.subclase_id = xx.subclase_id  limit 1)
            else 'Sin Parametrizacion'
        end as cuenta,
        case    when a.cuenta is not null then ccp.centro_de_costo_id
                when b.cuenta is not null then b.centro_costo_destino
                when c.cuenta is not null then ccp.centro_de_costo_id
                when d.cuenta is not null then d.centro_costo_destino
                when d.cuenta is null then (select xx.centro_costo_destino from cg_conf.doc_fv01_inv_grupos_productos_por_cc xx where cd.empresa_id = xx.empresa_id and ip.grupo_id = xx.grupo_id and ip.clase_id = xx.clase_id and ip.subclase_id = xx.subclase_id  limit 1)
            else 'Sin Parametrizacion'
        end as centro_costo,
        case when cu.estado = '0' then 'FACTURADO'
            else 'CARGADO'
        end as estado_cuenta,
        cd.valor_cargo,
        case when cd.cargo = 'DIMD' THEN cd.cantidad * (-1)
            else cd.cantidad
        end as cantidad
FROM    cuentas_detalle cd
        join departamentos dp on (cd.departamento = dp.departamento)
        join (
                SELECT  DISTINCT ON (ffc.numerodecuenta) numerodecuenta,
                        ff.prefijo,
                        ff.factura_fiscal,
                        ff.fecha_registro
                FROM    fac_facturas ff 
                        join fac_facturas_cuentas ffc 
                        on (ffc.empresa_id = ff.empresa_id and ffc.prefijo = ff.prefijo and ffc.factura_fiscal = ff.factura_fiscal)
                WHERE   ff.fecha_registro::date >= _1
                AND     ff.fecha_registro::date <= _2
                AND     ff.estado NOT IN ('2','3')
                ORDER BY ffc.numerodecuenta, ff.fecha_registro desc
            ) as cta_ff on (cd.numerodecuenta = cta_ff.numerodecuenta)
        join system_usuarios su on (cd.usuario_id = su.usuario_id)
        join bodegas_documentos_d bdd on (cd.consecutivo = bdd.consecutivo)
        join inventarios_productos ip on (bdd.codigo_producto = ip.codigo_producto)
        join cuentas cu on (cd.numerodecuenta = cu.numerodecuenta)
        join planes pl on (pl.plan_id = cu.plan_id)
        join cg_conf.centros_de_costo_departamentos ccp on (cd.departamento = ccp.departamento)
        left join cg_conf.doc_fv01_inv_productos a on (cd.empresa_id = a.empresa_id and ip.codigo_producto = a.codigo_producto)
        left join cg_conf.doc_fv01_inv_productos_por_cc b on (cd.empresa_id = b.empresa_id and ip.codigo_producto = b.codigo_producto and ccp.centro_de_costo_id = b.centro_de_costo_id)
        left join cg_conf.doc_fv01_inv_grupos_productos c on (cd.empresa_id = c.empresa_id and ip.grupo_id = c.grupo_id and ip.clase_id = c.clase_id and ip.subclase_id = c.subclase_id)
        left join cg_conf.doc_fv01_inv_grupos_productos_por_cc d on (cd.empresa_id = d.empresa_id and ip.grupo_id = d.grupo_id and ip.clase_id = d.clase_id and ip.subclase_id = d.subclase_id and ccp.centro_de_costo_id = d.centro_de_costo_id)
WHERE   cd.cargo  IN ('DIMD','IMD')
AND     ((cd.paquete_codigo_id IS NULL AND cd.facturado = '1') OR (cd.paquete_codigo_id IS NOT NULL AND cd.sw_paquete_facturado = '1'))
AND     cu.estado != '5'
ORDER BY 1,2
