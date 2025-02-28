SELECT 	FARMACIA.codigo_producto,
        FARMACIA.descripcion,
		SUM(FARMACIA.por05)por05,
		SUM(FARMACIA.por15)por15,
		SUM(FARMACIA.mes)mes
FROM(
	SELECT	IP.codigo_producto,
		IP.descripcion,
		SUM(MOV.salida - MOV.entrada)::int as por05,
		0 por15,
		0 mes
	FROM	(		
				SELECT	BN.prefijo,
						BDD.codigo_producto,
						CASE WHEN BN.tipo_movimiento = 'E' THEN BDD.cantidad
						ELSE 0
						END AS salida,
						CASE WHEN BN.tipo_movimiento = 'I' THEN BDD.cantidad
						ELSE 0
						END AS entrada
				FROM	bodegas_doc_numeraciones BN,
						bodegas_documentos BD,
						bodegas_documentos_d BDD
				WHERE	BD.fecha_registro::date BETWEEN _1::date - '5 days'::interval AND _1::date
				AND		BN.bodegas_doc_id = BD.bodegas_doc_id
				AND		BDD.bodegas_doc_id = BD.bodegas_doc_id
				AND		BDD.numeracion = BD.numeracion
				AND		BN.bodega = 'CI'
				AND		BN.prefijo IN ('DES','DEV')
				UNION ALL
				SELECT	BM.prefijo,
						BMD.codigo_producto,
						CASE WHEN TG.inv_tipo_movimiento = 'E' THEN BMD.cantidad
						ELSE 0
						END AS salida,
						CASE WHEN TG.inv_tipo_movimiento = 'I' THEN BMD.cantidad
						ELSE 0
						END AS entrada
				FROM	tipos_doc_generales TG,
						documentos D,
						inv_bodegas_movimiento BM,
						inv_bodegas_movimiento_d BMD
				WHERE	BM.fecha_registro::date BETWEEN _1::date - '5 days'::interval AND  _1::date
				AND		D.documento_id = BM.documento_id
				AND		TG.tipo_doc_general_id = D.tipo_doc_general_id
				AND		TG.inv_tipo_movimiento IN ('I','E')
				AND		BMD.empresa_id = BM.empresa_id
				AND		BMD.prefijo = BM.prefijo
				AND		BMD.numero = BM.numero
				AND		BM.bodega = 'CI'
				AND		BM.prefijo IN ('SA')
			) AS MOV,
			inventarios_productos IP
	WHERE	MOV.codigo_producto = IP.codigo_producto
	GROUP BY 1,2
	UNION ALL
	SELECT	IP.codigo_producto,
			IP.descripcion,
			0 por05,
			SUM(MOV.salida-MOV.entrada)::int por15,
			0 mes
	FROM	(		
				SELECT	BN.prefijo,
						BDD.codigo_producto,
						CASE WHEN BN.tipo_movimiento = 'E' THEN BDD.cantidad
						ELSE 0
						END AS salida,
						CASE WHEN BN.tipo_movimiento = 'I' THEN BDD.cantidad
						ELSE 0
						END AS entrada
				FROM	bodegas_doc_numeraciones BN,
						bodegas_documentos BD,
						bodegas_documentos_d BDD
				WHERE	BD.fecha_registro::date BETWEEN _1::date - '15 days'::interval AND _1::date
				AND		BN.bodegas_doc_id = BD.bodegas_doc_id
				AND		BDD.bodegas_doc_id = BD.bodegas_doc_id
				AND		BDD.numeracion = BD.numeracion
				AND		BN.bodega = 'CI'
				AND		BN.prefijo IN ('DES','DEV')
				UNION ALL
				SELECT	BM.prefijo,
						BMD.codigo_producto,
						CASE WHEN TG.inv_tipo_movimiento = 'E' THEN BMD.cantidad
						ELSE 0
						END AS salida,
						CASE WHEN TG.inv_tipo_movimiento = 'I' THEN BMD.cantidad
						ELSE 0
						END AS entrada
				FROM	tipos_doc_generales TG,
						documentos D,
						inv_bodegas_movimiento BM,
						inv_bodegas_movimiento_d BMD
				WHERE	BM.fecha_registro::date BETWEEN _1::date - '15 days'::interval AND _1::date
				AND		D.documento_id = BM.documento_id
				AND		TG.tipo_doc_general_id = D.tipo_doc_general_id
				AND		TG.inv_tipo_movimiento IN ('I','E')
				AND		BMD.empresa_id = BM.empresa_id
				AND		BMD.prefijo = BM.prefijo
				AND		BMD.numero = BM.numero
				AND		BM.bodega = 'CI'
				AND		BM.prefijo IN ('SA')
			) AS MOV,
			inventarios_productos IP
	WHERE	MOV.codigo_producto = IP.codigo_producto
	GROUP BY 1,2
	UNION ALL
	SELECT	IP.codigo_producto,
			IP.descripcion,
			0 por05,
			0 por15,
			SUM(MOV.salida-MOV.entrada)::int mes
	FROM	(		
				SELECT	BN.prefijo,
						BDD.codigo_producto,
						CASE WHEN BN.tipo_movimiento = 'E' THEN BDD.cantidad
						ELSE 0
						END AS salida,
						CASE WHEN BN.tipo_movimiento = 'I' THEN BDD.cantidad
						ELSE 0
						END AS entrada
				FROM	bodegas_doc_numeraciones BN,
						bodegas_documentos BD,
						bodegas_documentos_d BDD
				WHERE	BD.fecha_registro::date BETWEEN CONCAT(EXTRACT('year' FROM _1::date), '-',EXTRACT('month' FROM _1::date), '-01')::date AND _1::date
				AND		BN.bodegas_doc_id = BD.bodegas_doc_id
				AND		BDD.bodegas_doc_id = BD.bodegas_doc_id
				AND		BDD.numeracion = BD.numeracion
				AND		BN.bodega = 'CI'
				AND		BN.prefijo IN ('DES','DEV')
				UNION ALL
				SELECT	BM.prefijo,
						BMD.codigo_producto,
						CASE WHEN TG.inv_tipo_movimiento = 'E' THEN BMD.cantidad
						ELSE 0
						END AS salida,
						CASE WHEN TG.inv_tipo_movimiento = 'I' THEN BMD.cantidad
						ELSE 0
						END AS entrada
				FROM	tipos_doc_generales TG,
						documentos D,
						inv_bodegas_movimiento BM,
						inv_bodegas_movimiento_d BMD
				WHERE	BM.fecha_registro::date BETWEEN CONCAT(EXTRACT('year' FROM _1::date), '-',EXTRACT('month' FROM _1::date), '-01')::date AND _1::date
				AND		D.documento_id = BM.documento_id
				AND		TG.tipo_doc_general_id = D.tipo_doc_general_id
				AND		TG.inv_tipo_movimiento IN ('I','E')
				AND		BMD.empresa_id = BM.empresa_id
				AND		BMD.prefijo = BM.prefijo
				AND		BMD.numero = BM.numero
				AND		BM.bodega = 'CI'
				AND		BM.prefijo IN ('SA')
			) AS MOV,
			inventarios_productos IP
	WHERE	MOV.codigo_producto = IP.codigo_producto
	GROUP BY 1,2
) FARMACIA
GROUP BY 1,2
ORDER BY 1