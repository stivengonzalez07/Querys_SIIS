--query usuarios por departamento
SELECT
sc.usuario_id,
su.usuario,
su.nombre,
dc.descripcion as DESCRIPCION_DEPARTAMENTO,
sc.fecha_registro,
case   when sc.sw_estado = '1' then 'Activo'
        when sc.sw_estado = '0' then 'Inactivo'
end as estado
FROM 
system_usuarios_departamentos sc
INNER JOIN system_usuarios su ON (sc.usuario_id=su.usuario_id)
INNER JOIN departamentos ON ( sc.departamento=dc.departamento )

--quiery usuario responsables del cargo 
SELECT 
su.usuario_id, 
su.nombre,
ca.id_cargo,
pa.responsable as descripcion_cargo
from
system_usuarios su
inner join system_usuarios_cargos ca on (su.usuario_id=ca.usuario_id)
inner join plan_accion_responsable_listado pa on (ca.id_cargo=pa.id_responsable)