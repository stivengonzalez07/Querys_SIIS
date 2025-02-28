--QUERY USUARIOS SIIS - DICO
SELECT 
usuario_id,
usuario,
nombre,
descripcion,
passwd,
sw_admin,
activo,
telefono,
tel_celular,
email
FROM public.system_usuarios;