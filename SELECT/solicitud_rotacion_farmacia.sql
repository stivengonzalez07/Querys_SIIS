SELECT	IP.codigo_producto,
		IP.descripcion,
		SUM(MOV.entrada)::int as entradas,
		SUM(MOV.salida)::int as salidas,
		(SUM(MOV.salida)::int - SUM(MOV.entrada)::int) as total
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
			WHERE	BD.fecha::date >= _1
			AND		BD.fecha::date <= _2
			AND		BN.bodegas_doc_id = BD.bodegas_doc_id
			AND		BDD.bodegas_doc_id = BD.bodegas_doc_id
			AND		BDD.numeracion = BD.numeracion
			AND		BN.bodega = 'FA'
			AND		BN.prefijo IN ('DES','DEV','EV')
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
			WHERE	BM.fecha_registro::date >= _1
			AND		BM.fecha_registro::date <= _2
			AND		D.documento_id = BM.documento_id
			AND		TG.tipo_doc_general_id = D.tipo_doc_general_id
			AND		TG.inv_tipo_movimiento IN ('I','E')
			AND		BMD.empresa_id = BM.empresa_id
			AND		BMD.prefijo = BM.prefijo
			AND		BMD.numero = BM.numero
			AND		BM.bodega = 'FA'
			AND		BM.prefijo IN ('SA')
		) AS MOV,
		inventarios_productos IP
WHERE	MOV.codigo_producto = IP.codigo_producto
GROUP BY 1,2
ORDER BY 2