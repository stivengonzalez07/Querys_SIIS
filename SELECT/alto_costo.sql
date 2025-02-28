select 
CURRENT_TIMESTAMP as fecha_actual,
ip.codigo_producto as Codigo,
ip.descripcion as Descripcion,
u.descripcion as Unidad_medida,
ebf.existencia_actual as Cantidad_sistema,
0 as Cantidad_fisica,
ebf.lote as lote,
ebf.fecha_vencimiento::date as fecha_vencimiento,
b.descripcion as Bodega
from inventarios_productos ip
inner join unidades u ON(ip.unidad_id=u.unidad_id)
inner join existencias_bodegas eb on (eb.codigo_producto=ip.codigo_producto)
inner join bodegas b on (eb.bodega=b.bodega)
left join existencias_bodegas_lote_fv ebf on(eb.codigo_producto=ebf.codigo_producto and ebf.bodega=eb.bodega)
where ip.opc_costo_producto='3'
order by ip.codigo_producto

