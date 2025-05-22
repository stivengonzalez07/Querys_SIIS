SELECT
ebl.empresa_id
,ebl.centro_utilidad
,ebl.bodega
,ebl.codigo_producto
,fc_descripcion_producto(ebl.codigo_producto) AS descripcion_abreviada
,invpro.grupo_id
,invpro.clase_id
,invpro.subclase_id
,M.codigo_cum AS cum
,ebl.existencia_actual as existencia_bodega
,CASE WHEN M.sw_pos = '0' THEN 'NO POS' ELSE CASE WHEN M.sw_pos = '1' THEN 'POS' ELSE 'INSUMO' END END AS pos
,inv.costo
,inv.precio_venta
,(inv.costo * ebl.existencia_actual)	AS valor_stock
, ebl.fecha_vencimiento
, ebl.lote
,eb.existencia
/*Nombres de la empresa, Centro de Utilidad y Bodega. Se hizo asi para evitar pegar mas tablas con JOIN al query*/
,(SELECT razon_social FROM empresas AS emp WHERE emp.empresa_id=ebl.empresa_id) AS nombre_empresa
,(SELECT descripcion FROM centros_utilidad AS cu WHERE cu.empresa_id=ebl.empresa_id AND cu.centro_utilidad=ebl.centro_utilidad) AS nombre_centro_utilidad
,(SELECT descripcion FROM bodegas AS bod WHERE bod.empresa_id=ebl.empresa_id AND bod.centro_utilidad=ebl.centro_utilidad AND bod.bodega=ebl.bodega) AS nombre_bodega
/*Nombres de Grupo, Clase y Subclase*/
,(SELECT descripcion FROM inv_grupos_inventarios AS grupinv WHERE grupinv.grupo_id=invpro.grupo_id) AS nombre_grupo_inventario
,(SELECT descripcion FROM inv_clases_inventarios AS claseinv WHERE claseinv.grupo_id=invpro.grupo_id AND claseinv.clase_id=invpro.clase_id) AS nombre_clase_inventario
,(SELECT descripcion FROM inv_subclases_inventarios AS subclaseinv WHERE subclaseinv.grupo_id=invpro.grupo_id AND subclaseinv.clase_id=invpro.clase_id AND subclaseinv.subclase_id=invpro.subclase_id) AS nombre_subclase_inventario
/*Se parte de aqui para obtener solo los productos que corresponden a una bodega especifica*/
FROM public.existencias_bodegas AS eb
/*Se utiliza para traer la clase, la subclase y el grupo del producto*/
LEFT  JOIN public.inventarios_productos AS invpro ON (eb.codigo_producto=invpro.codigo_producto)
LEFT JOIN public.inventarios AS inv ON (eb.empresa_id=inv.empresa_id AND eb.codigo_producto=inv.codigo_producto)
LEFT JOIN public.medicamentos M ON invpro.codigo_producto = M.codigo_medicamento
INNER JOIN bodegas B ON (eb.empresa_id = B.empresa_id AND eb.centro_utilidad = B.centro_utilidad AND eb.bodega = B.bodega)
INNER JOIN existencias_bodegas_lote_fv ebl ON ebl.codigo_producto=eb.codigo_producto and eb.bodega=ebl.bodega
WHERE eb.bodega ='90'
--AND $X{IN, invpro.grupo_id,grupo_inventario}
--AND CASE WHEN $P{existencia_cero} LIKE 'true' THEN TRUE ELSE eb.existencia>0 END
--AND CASE WHEN $P{producto} IS NOT NULL THEN eb.codigo_producto=$P{producto} ELSE TRUE END
--AND CASE WHEN $P{conteo_diario}  LIKE 'true' THEN invpro.sw_quimico='1' ELSE TRUE END
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
ORDER BY 1,2,3,6,5