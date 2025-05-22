--query error rips.usuarios[0].servicios.medicamentos[0].codDiagnosticoPrincipal

SELECT bd.*
FROM public.bodegas_documentos_d bd
JOIN public.cuentas_detalle cd ON bd.consecutivo = cd.consecutivo
JOIN public.fac_facturas_cuentas ffc ON cd.numerodecuenta = ffc.numerodecuenta
WHERE ffc.prefijo = 'FE' 
AND ffc.factura_fiscal = '420497'  -- Reemplazar con el número de factura específico
AND cd.cargo = 'IMD';
------
--2.0
SELECT cd.*, 
       cd.fecha_registro AS fecha_registro_bodega
FROM public.cuentas_detalle cd
JOIN public.bodegas_documentos_d bd ON cd.consecutivo = bd.consecutivo
JOIN public.fac_facturas_cuentas ffc ON cd.numerodecuenta = ffc.numerodecuenta
WHERE ffc.prefijo = 'FE' 
AND cd.cargo = 'IMD'-- Reemplazar con el número de factura específico
AND ffc.factura_fiscal = '420497';

--3.0
SELECT bd.*
FROM public.bodegas_documentos_d bd
JOIN public.cuentas_detalle cd ON bd.consecutivo = cd.consecutivo
JOIN public.fac_facturas_cuentas ffc ON cd.numerodecuenta = ffc.numerodecuenta
WHERE ffc.prefijo = 'FE' 
AND cd.cargo = 'IMD'
AND ffc.factura_fiscal = '420497';  -- Reemplazar con el número de factura específico

--
--4.0
SELECT bd.*, cd.departamento
FROM public.bodegas_documentos_d bd
JOIN public.cuentas_detalle cd ON bd.consecutivo = cd.consecutivo
JOIN public.fac_facturas_cuentas ffc ON cd.numerodecuenta = ffc.numerodecuenta
WHERE ffc.prefijo = 'FE' 
AND cd.cargo = 'IMD'
AND cd.departamento = '020101' --filtro departamento resonancia
AND ffc.factura_fiscal IN ('420497', '420498', '420499');  -- Reemplazar con los números de factura deseados

--SOLUCION
UPDATE public.bodegas_documentos_d bd
SET dx_ppal_id = 'T049',               
    tipo_profesional_id = 'CC',
    profesional_id = '91492203'  -- Mantiene su valor actual cedula para resonancia 91492203 julio cesar medina
FROM public.cuentas_detalle cd
JOIN public.fac_facturas_cuentas ffc ON cd.numerodecuenta = ffc.numerodecuenta
JOIN public.fac_facturas ff ON ffc.prefijo = ff.prefijo AND ffc.factura_fiscal = ff.factura_fiscal
WHERE bd.consecutivo = cd.consecutivo
AND ffc.prefijo = 'FE' 
AND ffc.factura_fiscal = '420497'  -- Reemplazar con el número de factura específico
AND cd.cargo = 'IMD'
AND ff.fecha_registro > '2025-02-01 00:00:00';

.


--prueba consulta facturas de resonancia
--4.0
SELECT bd.*, cd.departamento
FROM public.bodegas_documentos_d bd
JOIN public.cuentas_detalle cd ON bd.consecutivo = cd.consecutivo
JOIN public.fac_facturas_cuentas ffc ON cd.numerodecuenta = ffc.numerodecuenta
WHERE ffc.prefijo = 'FE' 
AND cd.cargo = 'IMD'
AND ffc.factura_fiscal IN (
    '414605', '414629', '414628', '414676', '414647', '414643', '415099', '420248', 
    '414639', '414638', '414636', '414633', '414632', '414630', '415036', '415006', 
    '415140', '414950', '415635', '415458', '415376', '415835', '415753', '416460', 
    '420122', '415478', '415777', '416468', '416216', '416065', '416055', '416052', 
    '416417', '416274', '417019', '417017', '416451', '416763', '416762', '416669', 
    '416605', '418710', '418508', '419146', '419505', '419475', '416774', '416770', 
    '416607', '417185', '417004', '416924', '416806', '416778', '417086', '417566', 
    '417467', '417391', '417342', '418077', '418264', '418095', '417983', '417874', 
    '417760', '418253', '417761', '418576', '418519', '418399', '419105', '418418', 
    '418402', '419125', '418959', '419700', '420256', '420221', '419544', '419543', 
    '419470', '419375', '419372', '419359', '419992', '419558', '419554', '419551', 
    '419550', '419697', '420151', '420497', '420206');


ALTER TABLE public.interface_datalab_resultados ADD descripcion_valor_referencia text NULL;
COMMENT ON COLUMN public.interface_datalab_resultados.descripcion_valor_referencia IS 'Valor de ferencia para los analitos';



---

SELECT COUNT(*) 
FROM public.fac_facturas 
WHERE estado = '1';


SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'fac_facturas' 
AND column_name = 'estado';

SELECT * 
FROM public.fac_facturas 
WHERE estado = '1';

SELECT DISTINCT fecha_registro 
FROM public.fac_facturas 
ORDER BY fecha_registro DESC;


SELECT f.*
FROM public.fac_facturas f
WHERE f.tipo_factura = '1' 
  AND f.estado = '1' 
  AND f.fecha_registro BETWEEN '2025-02-01 00:00:00' AND NOW();


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
    COALESCE(CONCAT_WS(' ', u.primer_nombre, u.segundo_nombre, u.primer_apellido, u.segundo_apellido), 'SIN REGISTRO') AS nombre_usuario_factura
FROM 
    public.fac_facturas f
LEFT JOIN 
    public.auditoria_rips_electronicos a 
    ON f.prefijo = a.prefijo_factura 
    AND f.factura_fiscal = a.factura_fiscal
LEFT JOIN 
    public.system_usuarios u 
    ON f.usuario_id = u.usuario_id
WHERE 
    f.tipo_factura = '1'  -- Eliminamos comillas, ya que es un número
    AND f.estado = '0'    -- Filtramos solo las facturas en estado 0 (facturadas)
    AND f.fecha_registro BETWEEN '2025-02-01 00:00:00' AND NOW();





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
    i.fecha_registro AS "SALIDA PACIENTE"  -- Fecha de salida del paciente
FROM 
    public.fac_facturas f
LEFT JOIN 
    public.fac_facturas_cuentas ffc 
    ON f.prefijo = ffc.prefijo 
    AND f.factura_fiscal = ffc.factura_fiscal
LEFT JOIN 
    public.cuentas c 
    ON ffc.numerodecuenta = c.numerodecuenta
LEFT JOIN 
    public.ingresos_salidas i 
    ON c.ingreso = i.ingreso  -- Relación con la tabla ingresos_salidas
LEFT JOIN 
    public.auditoria_rips_electronicos a 
    ON f.prefijo = a.prefijo_factura 
    AND f.factura_fiscal = a.factura_fiscal
LEFT JOIN 
    public.system_usuarios u 
    ON f.usuario_id = u.usuario_id
WHERE 
    f.tipo_factura='1' --in ()'1','5')  -- Eliminamos comillas, ya que es un número
    and i.fecha_registro BETWEEN '2025-02-01 00:00:00' AND NOW()  -- Filtro para fechas desde el 1 de febrero hasta la fecha actual
ORDER BY 
    i.fecha_registro DESC NULLS LAST;  -- Ordena por fecha de salida del paciente
    
    
    
    
    select * from
    os_maestro as om
    inner join cups as c on c.cargo = om.cargo_cups
    inner join departamentos_cargos as dc on dc.cargo = c.cargo
    inner join departamentos as d on d.departamento = dc.departamento
where
    om.numero_orden_id = 2738162
    and d.sw_enviar_solicitudes = '1'
    
    
    select
    *
from
    os_maestro as om
    inner join cups as c on c.cargo = om.cargo_cups
    inner join departamentos_cargos as dc on dc.cargo = c.cargo
    inner join departamentos as d on d.departamento = dc.departamento
where
    om.numero_orden_id = 2738162
    and d.sw_enviar_solicitudes = '1';
    
    
    
    SELECT
    om.numero_orden_id AS orden_his,
    'CALI' AS id_sede,
    s.descripcion AS cod_tipo_atencion,
    oos.plan_id AS cod_tipo_plan,
    p.tipo_id_paciente AS tipodocumento,
    p.paciente_id AS numeroidentificacion,
    p.primer_nombre AS nombre1,
    p.segundo_nombre AS nombre2,
    p.primer_apellido AS apellido1,
    p.segundo_apellido AS apellido2,
    p.sexo_id AS genero,
    p.fecha_nacimiento AS fechanacimiento,
    p.residencia_direccion AS direccion,
    p.celular_telefono AS celular,
    p.residencia_telefono AS telefono,
    p.email AS email,
    om.cargo_cups
FROM
    os_maestro AS om
    INNER JOIN os_ordenes_servicios AS oos ON oos.orden_servicio_id = om.orden_servicio_id
    INNER JOIN servicios AS s ON oos.servicio = s.servicio
    INNER JOIN pacientes AS p ON p.paciente_id = oos.paciente_id
    AND p.tipo_id_paciente = oos.tipo_id_paciente
WHERE
    om.numero_orden_id = 2738162
    
    
    
    
    
    
    
SELECT bd.*, cd.fecha_registro
FROM public.bodegas_documentos_d bd
JOIN public.cuentas_detalle cd ON bd.consecutivo = cd.consecutivo
JOIN public.fac_facturas_cuentas ffc ON cd.numerodecuenta = ffc.numerodecuenta
WHERE ffc.prefijo = 'FE' 
AND ffc.factura_fiscal = '421374'  -- Reemplazar con el número de factura a consultar
--AND cd.cargo = 'IMD';


SELECT concepto_resultado_examen_id AS id
            FROM conceptos_resultados_examenes
            WHERE homologacion_birads ='2'

            
            SELECT *
            FROM conceptos_resultados_examenes