--query para listado de ultimo login de los usuarios por fecha
select
su.usuario_id,
su.usuario,
su.nombre,
MAX(st.fecha) as log_DICO,
MAX(sl.fecha) as log_SIIS
FROM 
system_users_tmp_p st
INNER JOIN system_usuarios su ON (st.usuario_id=su.usuario)
INNER JOIN system_usuarios_log sl ON (sl.usuario_id=su.usuario_id)
group by su.usuario_id 
ORDER BY su.usuario_id DESC