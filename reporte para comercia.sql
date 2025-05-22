WITH edad_pacientes AS (
    SELECT
        P.tipo_id_paciente,
        P.paciente_id,
        P.primer_nombre,
        P.segundo_nombre,
        P.primer_apellido,
        P.segundo_apellido,
        P.sexo_id,
        EXTRACT(YEAR FROM AGE(P.fecha_nacimiento)) AS edad_exacta,
        P.tipo_mpio_id,  -- Campo agregado
        P.tipo_dpto_id   -- Campo agregado
    FROM pacientes P
)
SELECT
    TR.tipo_id_tercero,
    TR.tercero_id,
    TR.nombre_tercero,
    C.numerodecuenta,
    P.tipo_id_paciente,
    P.paciente_id,
    P.primer_nombre,
    P.segundo_nombre,
    P.primer_apellido,
    P.segundo_apellido,
    PL.plan_descripcion,
    D.descripcion AS depto,
    D1.descripcion AS depto_ingreso,
    D2.descripcion AS depto_actual,
    CD.fecha_cargo,
    CD.fecha_registro AS fecha_registro_detalle,
    COALESCE(IP.codigo_producto, tD.cargo) AS cod_cargo,
    tD.descripcion as cargo, 
    COALESCE((CD.cantidad * CASE WHEN tD.cargo = 'DIMD' THEN -1 ELSE 1 END), 0) AS cantidad,
    CASE 
        WHEN CD.paquete_codigo_id IS NOT NULL THEN 
            CASE 
                WHEN CD.sw_paquete_facturado = '1' THEN CD.VALOR_CARGO 
                ELSE 0 
            END 
        ELSE 
            CASE 
                WHEN CD.facturado = '1' THEN CD.VALOR_CARGO 
                ELSE 0 
            END 
    END AS total_cuenta,
    (CASE WHEN CD.paquete_codigo_id IS NOT NULL THEN
		CASE WHEN CD.sw_paquete_facturado = '1' THEN CD.valor_nocubierto ELSE 0 END ELSE CASE WHEN CD.facturado = '1' THEN CD.valor_nocubierto ELSE 0 END END) as valor_nocubierto,
    (CASE WHEN CD.paquete_codigo_id IS NOT NULL THEN
		CASE WHEN CD.sw_paquete_facturado = '1' THEN CD.valor_cubierto ELSE 0 END ELSE CASE WHEN CD.facturado = '1' THEN CD.valor_cubierto ELSE 0 END END) as valor_cubierto,
    CD.VALOR_CARGO AS precio_tari,
    CE.descripcion AS estado,
    CASE WHEN tD.cargo IN ('IMD', 'DIMD') THEN 'FARMACIA' ELSE 'CARGOS' END AS tipo_tarifario,
    USU.usuario,
    CASE WHEN CD.sw_liq_manual = '1' THEN 'TARIFA MANUAL' ELSE 'TARIFA SISTEMA' END AS tipo_tarifa,
    USU1.usuario AS usuario_cargue,
    CASE WHEN BDN.tipo_movimiento = 'I' THEN ((BDD.total_costo * BDD.cantidad) * -1) ELSE (BDD.total_costo * BDD.cantidad) END AS costo,
    BG.descripcion AS bodega,
    CASE 
        WHEN BG.sw_aprovechamiento = '1' THEN 'APROVECHAMIENTO' 
        WHEN BG.sw_aprovechamiento = '0' THEN 'NUEVO' 
        ELSE '' 
    END AS tipo_producto,
    FF.fecha_factura,
    FF.prefijo,
    FF.factura_fiscal,
    ISA.fecha_registro,
    CD.transaccion,
    CD.paquete_codigo_id,
    C.ingreso,
    PE.nombre as profesional_asignado,
    TC.descripcion AS tipo_cliente,
    P.sexo_id,
    P.edad_exacta, 
    dxi.tipo_diagnostico_id as Diag_ingreso,
    dxn.diagnostico_nombre, 
    TM.municipio AS ciudad_ips,
    P.tipo_mpio_id || '-' || P.tipo_dpto_id AS mpio_dpto_concatenado  -- Concatenación de los campos tipo_mpio_id y tipo_dpto_id
FROM
    cuentas C
INNER JOIN hc_diagnosticos_ingreso dxi ON dxi.ingreso = C.ingreso
INNER JOIN diagnosticos dxn ON dxn.diagnostico_id = dxi.tipo_diagnostico_id
INNER JOIN cuentas_estados CE ON C.estado = CE.estado
INNER JOIN system_usuarios USU ON C.usuario_id = USU.usuario_id
INNER JOIN ingresos I ON I.ingreso = C.ingreso
LEFT JOIN ingresos_salidas ISA ON ISA.ingreso = I.ingreso
LEFT JOIN (
    SELECT numerodecuenta, 
           LIST(DISTINCT FF.fecha_registro::TEXT) AS fecha_factura, 
           LIST(FF.prefijo::TEXT) AS prefijo, 
           LIST(FF.factura_fiscal::TEXT) AS factura_fiscal, 
           LIST(FF.tipo_servicio::TEXT) AS tipo_servicio
    FROM fac_facturas_cuentas FFC 
    INNER JOIN fac_facturas FF ON FFC.empresa_id = FF.empresa_id AND FFC.prefijo = FF.prefijo AND FFC.factura_fiscal = FF.factura_fiscal 
    GROUP BY numerodecuenta
) FF ON FF.numerodecuenta = C.numerodecuenta
INNER JOIN edad_pacientes P ON (I.tipo_id_paciente = P.tipo_id_paciente AND I.paciente_id = P.paciente_id)
INNER JOIN planes PL ON C.plan_id = PL.plan_id
LEFT JOIN tipos_cliente TC ON PL.tipo_cliente = TC.tipo_cliente
INNER JOIN terceros TR ON PL.tipo_tercero_id = TR.tipo_id_tercero AND PL.tercero_id = TR.tercero_id
INNER JOIN tipo_mpios TM ON TR.tipo_pais_id = TM.tipo_pais_id AND TR.tipo_dpto_id = TM.tipo_dpto_id AND TR.tipo_mpio_id = TM.tipo_mpio_id
INNER JOIN cuentas_detalle CD ON CD.numerodecuenta = C.numerodecuenta
LEFT JOIN tarifarios_detalle TD ON TD.tarifario_id = CD.tarifario_id AND TD.cargo = CD.cargo
LEFT JOIN departamentos D ON CD.departamento = D.departamento
LEFT JOIN departamentos D1 ON I.departamento = D1.departamento
LEFT JOIN departamentos D2 ON I.departamento_actual = D2.departamento
LEFT JOIN bodegas_documentos_d BDD ON CD.consecutivo = BDD.consecutivo
LEFT JOIN bodegas_doc_numeraciones BDN ON BDD.bodegas_doc_id = BDN.bodegas_doc_id
LEFT JOIN bodegas BG ON BDN.empresa_id = BG.empresa_id AND BDN.centro_utilidad = BG.centro_utilidad AND BDN.bodega = BG.bodega
LEFT JOIN inventarios_productos IP ON BDD.codigo_producto = IP.codigo_producto
INNER JOIN system_usuarios USU1 ON CD.usuario_id = USU1.usuario_id
LEFT JOIN cuentas_detalle_profesionales CDP ON CD.transaccion = CDP.transaccion
LEFT JOIN profesionales PE ON CDP.tipo_tercero_id = PE.tipo_id_tercero AND PE.tercero_id = CDP.tercero_id
LEFT JOIN (
    SELECT CCA.codigo_agrupamiento_id, 
           LIST(CUP.descripcion) AS acto_qx 
    FROM cuentas_codigos_agrupamiento CCA
    INNER JOIN cuentas_liquidaciones_qx_procedimientos CLQ ON CCA.cuenta_liquidacion_qx_id = CLQ.cuenta_liquidacion_qx_id
    INNER JOIN CUPS CUP ON CUP.cargo = CLQ.cargo_cups
    WHERE CCA.cuenta_liquidacion_qx_id IS NOT NULL
    GROUP BY CCA.codigo_agrupamiento_id
) QX ON QX.codigo_agrupamiento_id = CD.codigo_agrupamiento_id
where
CAST(CD.fecha_cargo AS DATE) BETWEEN  '01-04-2024'   AND  '30-05-2024'--CONDICIONES TEMPORALES
/*CAST(CD.fecha_cargo AS DATE) BETWEEN  $P{fecha_inicial}   AND  $P{fecha_final}
AND $X{IN ,CE.estado, estado_cuenta}
AND CASE WHEN $P{planes}  IS NOT  NULL THEN pl.plan_id = $P{planes} ELSE TRUE END
AND CASE WHEN $P{departamentos_lista} IS  NOT NULL THEN  
          CASE WHEN $P{tipo_departamento_cargue} = '1' THEN  $X{IN,D1.departamento,departamentos_lista}
			ELSE 
					CASE WHEN $P{tipo_departamento_cargue} = '2' THEN $X{IN,D2.departamento,departamentos_lista}
					 ELSE $X{IN,d.departamento,departamentos_lista}
					 END 
			END 
         ELSE TRUE END  
AND CASE WHEN $P{tipo_identificacion} IS NOT NULL THEN I.tipo_id_paciente = $P{tipo_identificacion} ELSE TRUE END
AND CASE WHEN $P{terceros} IS NOT NULL THEN TR.tercero_id = $P{terceros} ELSE TRUE END
AND CASE WHEN $P{identificacion} IS NOT NULL THEN I.paciente_id = $P{identificacion} ELSE TRUE END
AND CASE WHEN $P{cuenta} IS NOT NULL THEN C.numerodecuenta = $P{cuenta} ELSE TRUE END
AND CASE WHEN $P{usuario_cargue} IS NOT NULL THEN USU1.usuario = $P{usuario_cargue} ELSE TRUE END
AND $X{IN ,CD.cargo

, cargos}
AND CASE WHEN $P{tipo_cargue} IS NOT NULL THEN CASE WHEN $P{tipo_cargue} = '1' THEN td.cargo IN ('IMD','DIMD')
													WHEN $P{tipo_cargue} = '2' THEN td.cargo NOT IN ('IMD','DIMD')
													ELSE TRUE
													END ELSE TRUE END
