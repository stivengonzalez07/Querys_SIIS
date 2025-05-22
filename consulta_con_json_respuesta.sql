select
	auditoria_rips_electronicos_id,
	empresa_id,
	prefijo_factura,
	factura_fiscal,
	prefijo_nota,
	numero_nota,
	estado,
	cuv,
	json_rips,
	json_respuesta,
	fecha_registro,
	usuario_id
from
	public.auditoria_rips_electronicos;



SELECT 
  prefijo_factura,
  factura_fiscal,
  estado,
  json_respuesta->'ResultadosValidacion'->1->>'Codigo' AS codigo_2,
  json_respuesta->'ResultadosValidacion'->1->>'Descripcion' AS descripcion_2,
  json_respuesta->'ResultadosValidacion'->1->>'Observaciones' AS observaciones_2,
  fecha_registro,
  usuario_id
FROM public.auditoria_rips_electronicos
WHERE --estado = 'NO_VALIDADO'  AND 
  prefijo_factura = 'FE' and 
  fecha_registro between '2025-02-01' and now()
  
  
  
  
  
  
SELECT 
    f.prefijo,
    f.factura_fiscal,
    f.total_factura,
    f.valor_cuota_paciente AS copago,  
    f.valor_cuota_moderadora AS cuota_moderadora, 
    CASE 
        WHEN a.estado = 'NO_VALIDADO' THEN 'CON_ERRORES'
        WHEN a.estado = 'VALIDADO_CORRECTO' THEN 'RADICADA'
        ELSE 'SIN_VALIDACION' 
    END AS estado_auditoria,
    f.fecha_registro AS fecha_factura,
    f.usuario_id AS usuario_factura,
    CONCAT_WS(' ', u.primer_nombre, u.segundo_nombre, u.primer_apellido, u.segundo_apellido) AS nombre_usuario_factura,
    a.json_respuesta->'ResultadosValidacion'->1->>'Codigo' AS codigo_error_2,
    a.json_respuesta->'ResultadosValidacion'->1->>'Descripcion' AS descripcion_error_2,
    a.json_respuesta->'ResultadosValidacion'->1->>'Observaciones' AS observaciones_error_2,
    a.json_respuesta::text AS json_respuesta_completo
FROM public.fac_facturas f
LEFT JOIN public.auditoria_rips_electronicos a 
    ON f.prefijo = a.prefijo_factura 
    AND f.factura_fiscal = a.factura_fiscal
LEFT JOIN public.system_usuarios u 
    ON f.usuario_id = u.usuario_id
WHERE 
    f.tipo_factura = '1'
--  AND f.estado = '0'
    AND f.fecha_registro BETWEEN '2025-02-01 00:00:00' AND NOW();  