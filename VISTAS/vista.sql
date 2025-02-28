CREATE VIEW view_cuentas_detalle_productos AS
SELECT  C.numerodecuenta,
		ID.codigo_producto, 
              C.cantidad, 
              C.valor_cubierto,
              C.valor_cargo,
              TO_CHAR(C.fecha_cargo,'DD/MM/YYYY') AS fecha_cargo,
              DE.departamento,
              DE.descripcion AS departamento_descripcion,
              fc_descripcion_producto(ID.codigo_producto) AS descripcion, 
              C.transaccion 
       FROM   ( 
                SELECT  SUM(cantidad) AS cantidad, 
                        SUM(valor_cubierto) AS valor_cubierto, 
                        SUM(valor_cargo) AS valor_cargo, 
                        MAX(a.fecha_cargo) AS fecha_cargo, 
                        COUNT(*) AS transaccion, 
						numerodecuenta,
                        codigo_producto, 
                        departamento 
                FROM    (      
                          (  
                            SELECT  SUM(COALESCE(CD.cantidad,0)) as cantidad,  
                                    CD.fecha_cargo::date, 
                                    CD.departamento, 
                                    BD.codigo_producto,
									CD.numerodecuenta,
                                    SUM(COALESCE(CD.valor_cubierto,0)) as valor_cubierto, 
                                    SUM(COALESCE(CD.valor_cargo,0)) as valor_cargo 
                            FROM    cuentas_detalle CD, 
                                    bodegas_documentos_d BD  
                            WHERE   CD.tarifario_id = 'SYS'  
                            AND     CD.cargo = 'IMD' 
                            AND        ((CD.facturado = '1' AND CD.paquete_codigo_id IS NULL) OR 
                                     (CD.sw_paquete_facturado = '1' AND CD.paquete_codigo_id IS NOT NULL)) 
                            AND         CD.consecutivo = BD.consecutivo 
                            AND     CD.valor_cargo > 0 
                            GROUP BY 2,3,4,5 
                            ORDER BY BD.codigo_producto 
                          ) 
                          UNION ALL 
                          (  
                            SELECT  (SUM(COALESCE(CD.cantidad,0))*-1) as cantidad,  
                                    CD.fecha_cargo::date,  
                                    CD.departamento,  
                                    BD.codigo_producto, 
									CD.numerodecuenta,
                                    (SUM(COALESCE((CD.valor_cubierto *-1),0))*-1) as valor_cubierto,
                                    (SUM(COALESCE((CD.valor_cargo*-1),0))*-1) as valor_cargo 
                            FROM    cuentas_detalle CD,  
                                    bodegas_documentos_d BD  
                            WHERE   CD.tarifario_id = 'SYS' 
                            AND     CD.cargo = 'DIMD' 
                            AND         ((CD.facturado = '1' AND CD.paquete_codigo_id IS NULL) OR 
                                      (CD.sw_paquete_facturado = '1' AND CD.paquete_codigo_id IS NOT NULL)) 
                            AND         CD.consecutivo = BD.consecutivo  
                            GROUP BY 2,3,4,5 
                            ORDER BY BD.codigo_producto 
                          ) 
                        ) A  
                GROUP BY 6,7,8  
              ) C , 
              departamentos DE, 
              inventarios_productos ID,
			  cuentas CU
       WHERE  C.codigo_producto = ID.codigo_producto 
       AND    C.departamento = DE.departamento 
       AND    C.cantidad <> 0 
	   AND	  C.numerodecuenta=CU.numerodecuenta
	   AND    CU.estado!='5'
	   ORDER BY C.numerodecuenta, ID.codigo_producto 