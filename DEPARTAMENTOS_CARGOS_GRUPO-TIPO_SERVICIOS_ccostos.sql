SELECT 
    dc.departamento,
    d.descripcion AS nombre_departamento,
    dc.cargo,
    LEFT(c.descripcion, 40) AS nombre_cargo,
    dc.tipos_servicios_id,
    ts.descripcion AS nombre_tipo_servicio,
    ts.grupos_servicios_id,
    gs.descripcion AS nombre_grupo_servicio
FROM public.departamentos_cargos dc
LEFT JOIN public.departamentos d ON dc.departamento = d.departamento
LEFT JOIN public.cups c ON dc.cargo = c.cargo
LEFT JOIN public.tipos_servicios ts ON dc.tipos_servicios_id = ts.tipos_servicios_id
LEFT JOIN public.grupos_servicios gs ON ts.grupos_servicios_id = gs.grupos_servicios_id;




SELECT 
    ccd.centro_de_costo_id,
    dc.departamento,
    d.descripcion AS nombre_departamento,
    dc.cargo,
    LEFT(c.descripcion, 40) AS nombre_cargo,
    dc.tipos_servicios_id,
    ts.descripcion AS nombre_tipo_servicio,
    ts.grupos_servicios_id,
    gs.descripcion AS nombre_grupo_servicio
FROM public.departamentos_cargos dc
LEFT JOIN public.departamentos d ON dc.departamento = d.departamento
LEFT JOIN public.cups c ON dc.cargo = c.cargo
LEFT JOIN public.tipos_servicios ts ON dc.tipos_servicios_id = ts.tipos_servicios_id
LEFT JOIN public.grupos_servicios gs ON ts.grupos_servicios_id = gs.grupos_servicios_id
LEFT JOIN cg_conf.centros_de_costo_departamentos ccd ON dc.departamento = ccd.departamento
where c.sw_estado ='1';


