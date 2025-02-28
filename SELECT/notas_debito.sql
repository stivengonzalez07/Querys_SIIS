SELECT nd.prefijo||' '||nd.nota_debito_id as nota_debito,
nd.prefijo_factura||' '||nd.factura_fiscal as factura,
nd.valor_nota,
TO_CHAR(nd.fecha_registro,'YYYY-MM-DD') AS fecha_registro,
nd.tipo_id_tercero||' '||nd.tercero_id as tercero,
t.nombre_tercero,
ndc.descripcion as concepto,
nd.observacion

FROM notas_debito nd 
INNER JOIN terceros t ON nd.tipo_id_tercero=t.tipo_id_tercero AND nd.tercero_id=t.tercero_id
LEFT JOIN notas_debito_detalle_conceptos ndd ON nd.nota_debito_id=ndd.nota_debito_id AND nd.prefijo=ndd.prefijo
LEFT JOIN notas_credito_ajuste_conceptos ndc ON ndd.nota_debito_concepto_id=ndc.concepto_id
WHERE nd.estado='1'
AND nd.fecha_registro::date BETWEEN _1 AND _2
ORDER BY 1