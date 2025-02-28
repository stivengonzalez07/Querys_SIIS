SELECT  fc.*,
        CASE    WHEN e.fecha_radicacion IS NULL THEN 'SIN RADICAR'
                ELSE 'RADICADO' 
        END AS ESTADO_RADICACION, 
        e.envio_id AS nro_envio, 
        CASE    WHEN e.sw_estado='1' THEN 'ACTIVO'
                WHEN e.sw_estado='2' THEN 'ANULADO'
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
								and    ng.acta_conciliacion_id IS NULL
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
                    case when ff.prefijo is null then 0
                        else (
                                select sum(acgd.valor_aceptado_ips)
                                from   actas_conciliacion_glosas_detalle acgd 
                                join actas_conciliacion_glosas acg ON (acgd.acta_conciliacion_id = acg.acta_conciliacion_id)
                                where  ff.factura_fiscal = acgd.factura_fiscal 
                                and    ff.prefijo = acgd.prefijo
                                and    ff.empresa_id = acgd.empresa_id
                                and    acg.sw_activo = '1'
                            )
                    end as valor_acta_aceptado_ips,
                    ff.saldo as saldo_factura,
                    CASE    WHEN ff.estado = '0' THEN 'FACTURADO'
                            WHEN ff.estado = '1' THEN 'PAGADO'
                            WHEN ff.estado = '2' THEN 'ANULADO'
                            WHEN ff.estado = '3' THEN 'ANULADA CON NOTA'
                            WHEN ff.estado IS NULL THEN 'SIN FACTURA'
                        ELSE 'SIN ESTADO'
                    END AS estado_factura,
                    CASE  WHEN ins.fecha_registro IS NOT NULL THEN TO_CHAR(ins.fecha_registro,'YYYY-MM-DD')
						  WHEN ins.fecha_registro IS NULL AND sal.estado='1' THEN 'SIN FECHA EGRESO'
					      WHEN ins.fecha_registro IS NULL AND he.fecha_egreso IS NOT NULL  THEN he.fecha_egreso
					    ELSE TO_CHAR(i.fecha_registro,'YYYY-MM-DD')
					END AS fecha_egreso,
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
            left join ingresos_salidas ins on (ins.ingreso = i.ingreso)
            LEFT JOIN (
					select TO_CHAR(max(fecha),'YYYY-MM-DD') AS fecha_egreso, 
					ingreso 
					FROM hc_evoluciones 
					GROUP BY ingreso) 
				AS he ON (he.ingreso = i.ingreso)
			LEFT JOIN (select pu.ingreso, i.estado
					from pacientes_urgencias pu, ingresos i, cuentas cu 
					where pu.ingreso=i.ingreso and i.ingreso=cu.ingreso
					and pu.sw_estado='1' and i.estado='1' and cu.estado in ('1','2')
					union all
					select mh.ingreso, i.estado 
					from movimientos_habitacion mh, ingresos i
					where mh.ingreso=i.ingreso
					and mh.fecha_egreso is null
					and i.estado='1')
				AS sal ON (sal.ingreso=i.ingreso)
			join cuentas c on (i.ingreso = c.ingreso)
            left join (
                    select  f.*,
                            ffc.numerodecuenta
                    from    fac_facturas f
                        left join fac_facturas_cuentas ffc on (f.empresa_id = ffc.empresa_id and f.prefijo = ffc.prefijo and f.factura_fiscal = ffc.factura_fiscal)
                    where f.estado NOT IN ('2','3')
					and f.tipo_factura != '0'			
                ) ff on (ff.numerodecuenta = c.numerodecuenta)
            join pacientes pa on (i.tipo_id_paciente = pa.tipo_id_paciente and i.paciente_id = pa.paciente_id)
            join departamentos de on (i.departamento = de.departamento) 
            join departamentos dea on (i.departamento_actual = dea.departamento)
            left join system_usuarios su on (c.usuario_id = su.usuario_id)
            join planes pl on (c.plan_id = pl.plan_id)
            WHERE   i.fecha_ingreso::date BETWEEN _1 AND _2
            AND     c.estado != '5'
            ORDER BY i.ingreso, c.numerodecuenta
        ) fc
        left join envios e on (fc.envio_id = e.envio_id)

