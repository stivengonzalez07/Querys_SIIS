select 
inv.id as num_dispo,
ti.nombre as descripcion_dispo,
sti.nombre as subtipo,
pro.nombre as desc_proveedor,
inv.factura,
inv.area as area_asig,
inv.fecha as fecha_registros,
inv.numeroactivo,
inv.precio_compra, 
inv.sw_estado
from 
inventariotic."inventario" inv
inner join inventariotic."proveedor" pro on (inv.id_proveedor=pro.id)
inner join inventariotic."tipo" ti on (inv.id_tipo = ti.id)
inner join inventariotic."subtipo"  sti on (inv.id_tipo = sti.id)
inner join public.departamentos
where sw_estado ='1'


--------------------------
select * 
from inventariotic."inventario" 

------
select 
inv.id as num_dispo,
ti.nombre as descripcion_dispo,
sti.nombre as subtipo,
pro.nombre as desc_proveedor,
inv.factura,
d.descripcion as area_asig,
inv.fecha as fecha_registros,
inv.numeroactivo,
inv.precio_compra, 
inv.sw_estado
from 
inventariotic."inventario" inv
inner join inventariotic."proveedor" pro on (inv.id_proveedor=pro.id)
inner join inventariotic."tipo" ti on (inv.id_tipo = ti.id)
inner join inventariotic."subtipo"  sti on (inv.id_tipo = sti.id)
inner join public.departamentos d on (d.departamento=inv.area)
where sw_estado ='1'