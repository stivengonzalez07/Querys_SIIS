SELECT
		 ING.tipo_id_paciente
		,ING.documento
		,ING.paciente
		,ING.edad
		,ING.sexo_id
		,ING.ingreso
		,ING.plan
		,ING.fecha_ingreso
		,ING.tipo_atencion
		,ING.total_factura
		,ING.diagnostico_ingreso1
		,ING.diagnostico_ingreso_dos
		,ING.diagnostico_egreso
		,ING.diagnostico_egreso_dos
		,ING.fecha_egreso
		,ING.tel1
		,ING.tel2
		,ING.direccion
		,ING.municipio
		,ING.departamento
		,ING.descripcion
		,ING.via_ingreso_nombre
		,ING.departamento_sal
		,ING.departamento_actual
		,ING.estado_salida
		,ING.dias_estancia
		,ING.hora_estancia
		,CASE WHEN ING.fecha_egreso ISNULL THEN NULL  ELSE
         CASE WHEN ING.fecha_egreso IS NOT NULL THEN((ING.dias_estancia * 24) + ING.hora_estancia)END END  AS estancia
		,ING.tuvo_qx
		,ING.porcedi
		,ING.numerodecuenta
		,ING.total_cuenta
	FROM
		(SELECT
			INGRE.tipo_id_paciente
			,INGRE.documento
			,INGRE.paciente
			,INGRE.edad
			,INGRE.sexo_id
			,INGRE.ingreso
			,INGRE.plan
			,INGRE.fecha_ingreso
			,INGRE.tipo_atencion
			,INGRE.total_factura
			,INGRE.diagnostico_ingreso1
			,INGRE.diagnostico_ingreso_dos
			,INGRE.diagnostico_egreso
			,INGRE.diagnostico_egreso_dos
			,INGRE.fecha_egreso
			,INGRE.residencia_telefono as tel1
			,INGRE.celular_telefono as tel2
			,INGRE.residencia_direccion as direccion
			,INGRE.tipo_mpio_id as municipio
			,INGRE.departamento
			,INGRE.descripcion
			,INGRE.via_ingreso_nombre
			,INGRE.departamento_sal
			,INGRE.departamento_actual
			, CASE WHEN INGRE.estado_salida in ('99','06') THEN 'VIVO' ELSE
			  CASE WHEN INGRE.estado_salida in ('07') THEN 'MUERTO' END END AS estado_salida
			,(SELECT (DATE_PART('day', (INGRE.fecha_egreso::timestamp ) - (INGRE.fecha_ingreso::timestamp ) ))) AS dias_estancia
			,(SELECT (DATE_PART('hour',(INGRE.fecha_egreso::timestamp )- (INGRE.fecha_ingreso::timestamp  ) ))) AS hora_estancia
			, CASE WHEN INGRE.tuvo_qx  ISNULL THEN 'NO' ELSE
			  CASE WHEN INGRE.tuvo_qx  IS NOT NULL THEN 'SI'  END END AS tuvo_qx
			 , ( SELECT  LIST(CS.descripcion) FROM  cups CS INNER JOIN hc_notas_operatorias_procedimientos HCN ON HCN.procedimiento_qx=CS.cargo INNER JOIN hc_descripcion_cirugia HCQ ON        HCQ.hc_nota_operatoria_cirugia_id=HCN.hc_nota_operatoria_cirugia_id 	WHERE INGRE.ingreso=HCQ.ingreso ) as porcedi
			 ,LIST(INGRE.numerodecuenta::TEXT) AS numerodecuenta
			 ,SUM(INGRE.total_cuenta) AS total_cuenta
		FROM
					(  SELECT
						 PA.tipo_id_paciente
						,PA.paciente_id AS documento
						,(PA.primer_apellido ||' '|| PA.segundo_apellido ||' '|| PA.primer_nombre ||' '|| PA.segundo_nombre) AS paciente
						,edad(PA.fecha_nacimiento) AS edad
						,PA.sexo_id
						,I.ingreso
						,I.departamento_actual
						,I.departamento
						,D.descripcion
						,PA.tipo_mpio_id
						,PA.residencia_telefono
						,PA.celular_telefono
						,PA.residencia_direccion
						,(SELECT LIST(P.plan_descripcion) AS plan FROM cuentas C INNER JOIN planes P ON C.plan_id = P.plan_id WHERE C.ingreso = I.ingreso) AS plan
						,I.fecha_ingreso
						,V.via_ingreso_nombre
						,(SELECT SUM(FF.total_factura) FROM cuentas CU INNER JOIN fac_facturas_cuentas FFC ON FFC.numerodecuenta=CU.numerodecuenta  INNER JOIN fac_facturas FF ON FF.factura_fiscal=FFC.factura_fiscal WHERE CU.ingreso = I.ingreso) AS total_factura
						,(SELECT LIST(dx.diagnostico_id ||' - '|| dx.diagnostico_nombre)
						  FROM hc_evoluciones HE
						   INNER JOIN hc_diagnosticos_ingreso hcd ON hcd.evolucion_id=HE.evolucion_id
							INNER JOIN diagnosticos dx ON dx.diagnostico_id= hcd.tipo_diagnostico_id
							WHERE hcd.sw_principal='1' AND HE.ingreso = I.ingreso) AS diagnostico_ingreso1
						,(SELECT LIST(dx.diagnostico_id ||' - '|| dx.diagnostico_nombre)
							FROM hc_evoluciones HE
							 INNER JOIN hc_diagnosticos_ingreso hcd ON hcd.evolucion_id=HE.evolucion_id
							 INNER JOIN diagnosticos dx ON dx.diagnostico_id= hcd.tipo_diagnostico_id
							 WHERE hcd.sw_principal='0' AND HE.ingreso = I.ingreso) AS diagnostico_ingreso_dos
						,(SELECT LIST(dx.diagnostico_id ||' - '|| dx.diagnostico_nombre)
							FROM hc_evoluciones HE
							  INNER JOIN hc_diagnosticos_egreso hcd ON hcd.evolucion_id=HE.evolucion_id
							  INNER JOIN diagnosticos dx ON dx.diagnostico_id= hcd.tipo_diagnostico_id
							WHERE hcd.sw_principal='1' AND HE.ingreso = I.ingreso) AS diagnostico_egreso
						,(SELECT LIST(dx.diagnostico_id ||' - '|| dx.diagnostico_nombre)
							FROM hc_evoluciones HE
							  INNER JOIN hc_diagnosticos_egreso hcd ON hcd.evolucion_id=HE.evolucion_id
							  INNER JOIN diagnosticos dx ON dx.diagnostico_id= hcd.tipo_diagnostico_id
							WHERE hcd.sw_principal='0' AND HE.ingreso = I.ingreso) AS diagnostico_egreso_dos
						,CASE WHEN S.servicio in ('0','5','8','3','9','7') THEN (SELECT ING.fecha_ingreso FROM  ingresos ING where I.ingreso=ING.ingreso)ELSE
						 CASE WHEN S.servicio in ('1','6','2','4') THEN
						(SELECT MIN(ING.fecha_registro) FROM hc_vistosok_salida_detalle	 ING WHERE ING.ingreso=I.ingreso) END END  as fecha_egreso
						,CASE WHEN S.servicio in ('0','5','8','3','9','7') THEN 'AMBULATORIO' ELSE
						 CASE WHEN S.servicio in ('1','6','2','4') THEN 'HOSPITALARIO' END END  as tipo_atencion
					   ,(SELECT LIST(HCO.hc_tipo_orden_medica_id)  FROM hc_ordenes_medicas HCO WHERE I.ingreso=HCO.ingreso AND HCO.sw_estado='0') as estado_salida
					   ,(SELECT LIST(HCO.hc_tipo_orden_medica_id:: TEXT)  FROM hc_ordenes_medicas HCO WHERE I.ingreso=HCO.ingreso AND hc_tipo_orden_medica_id='05' ) as tuvo_qx
					   , D1.descripcion as departamento_sal
					   ,CU.numerodecuenta
					   ,CU.total_cuenta
						FROM	pacientes PA
						INNER JOIN ingresos I ON I.tipo_id_paciente=PA.tipo_id_paciente AND I.paciente_id=PA.paciente_id
						INNER JOIN departamentos D ON D.departamento=I.departamento
						INNER JOIN servicios S ON S.servicio=D.servicio
						INNER JOIN vias_ingreso V ON V.via_ingreso_id=I.via_ingreso_id
						INNER JOIN departamentos D1 ON D1.departamento=I.departamento_actual
						INNER JOIN cuentas CU ON CU.ingreso=I.ingreso
						INNER JOIN planes PL ON CU.plan_id = PL.plan_id
						INNER JOIN tipo_mpios TM ON PA.tipo_mpio_id = TM.tipo_mpio_id
						WHERE   CASE WHEN $P{cuenta} IS NOT NULL THEN CU.numerodecuenta = $P{cuenta} ELSE TRUE END
						AND CASE WHEN $P{terceros} IS NOT NULL THEN PL.tercero_id = $P{terceros} ELSE TRUE END
		)AS INGRE
		GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29) AS ING
		   WHERE   CASE WHEN $P{ingresos} = 1 THEN CAST(ING.fecha_ingreso AS DATE) BETWEEN $P{fecha_inicial}  AND $P{fecha_final} ELSE CASE WHEN $P{ingresos} = 2 THEN CAST(ING.fecha_egreso AS DATE) BETWEEN $P{fecha_inicial}  AND $P{fecha_final} END END
	       AND CASE WHEN $P{departamentos} IS NOT NULL THEN ING.departamento_actual = $P{departamentos} ELSE TRUE END
		   AND CASE WHEN $P{identificacion} IS NOT NULL THEN ING.documento= $P{identificacion} ELSE TRUE END

