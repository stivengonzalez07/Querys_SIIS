SELECT 
  a.prefijo_factura,
  a.factura_fiscal,
  a.estado,
  a.cuv,
  trim(both '{}' from cuv_match.match[1]) AS codigo_cuv,
  a.fecha_registro,
  a.usuario_id
FROM 
  public.auditoria_rips_electronicos a

LEFT JOIN LATERAL (
  SELECT regexp_matches(a.json_respuesta::text, 'CUV\s*[:\-]?\s*[{"]?([a-f0-9]{64,128})[}"]?', 'i') AS match
) cuv_match ON true

WHERE 
  a.json_respuesta::text ~* 'CUV'
  AND a.prefijo_factura = 'FE'
  and a.fecha_registro between '2025-03-14' and now()