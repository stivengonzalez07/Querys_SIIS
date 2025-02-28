	SELECT cc.*, e.envio_id, e.fecha_radicacion
	FROM 
	(
	SELECT  rcd.numerodecuenta,
		rc.relacion_id,
		rc.fecha_registro,
			CASE
				WHEN rcd.estado = 'R'::bpchar THEN 'RELACIONADO'::text
				ELSE 'ENTREGADO'::text
			END AS estado_relacion,
		rcd.prefijo,
		rcd.factura_fiscal,
		ff.fecha_registro as fecha_factura,
		rcd.total_cuenta,
		p.plan_descripcion,
		sui.nombre AS usuario_entrega,
		de.descripcion AS departamento_entrega,
		su.nombre AS usuario_recibe,
		d.descripcion AS departamento_recibe,
		rc.fecha_recibe,
		c.fecha_registro AS fecha_Ingreso,
		ins.fecha_registro AS fecha_egreso,
		rcd.observacion
	FROM relacion_cuentas_detalle rcd
		JOIN relacion_cuentas rc ON rc.relacion_id = rcd.relacion_id
		LEFT JOIN cuentas c ON rcd.numerodecuenta = c.numerodecuenta
		--LEFT JOIN fac_facturas_cuentas ffc ON ffc.numerodecuenta = c.numerodecuenta
		LEFT JOIN fac_facturas ff ON ff.factura_fiscal = rcd.factura_fiscal AND ff.prefijo=rcd.prefijo
		LEFT JOIN planes p ON c.plan_id = p.plan_id
		LEFT JOIN system_usuarios su ON rc.usuario_recibe = su.usuario_id
		LEFT JOIN system_usuarios sui ON rc.usuario_entrega = sui.usuario_id
		LEFT JOIN departamentos_control_cuentas d ON rc.departamento_recibe::text = d.departamento::text
		LEFT JOIN departamentos_control_cuentas de ON rc.departamento_entrega::text = de.departamento::text
		INNER JOIN ingresos i ON c.ingreso = i.ingreso
        LEFT JOIN ingresos_salidas ins ON i.ingreso=ins.ingreso		   
	WHERE 	rc.fecha_registro::date BETWEEN  _1 AND _2
	ORDER BY rcd.numerodecuenta, rcd.rel_det_id DESC
	) AS cc
	LEFT JOIN envios_detalle ed ON (cc.prefijo=ed.prefijo AND cc.factura_fiscal=ed.factura_fiscal)
	LEFT JOIN envios e ON (ed.envio_id=e.envio_id)

